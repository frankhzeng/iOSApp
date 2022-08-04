/*[
 List(title: "SAT", words: [
   Word(word: "taciturn", def: "reserved or saying little"),
   Word(word: "unction", def: "an excessive, affected, sometimes cloying earnestness or fervor in manner, especially in speaking."),
   Word(word: "officious", def: "overly meddlesome"),
   Word(word: "loquacious", def: "tending to talk a great deal; talkative"),
   Word(word: "laconic", def: "using few words")]),
 List(title: "Science", words: [
   Word(word: "defenestrate", def: "throw someone out the window"),
   Word(word: "umbrage", def: "offense or annoyance"),
   Word(word: "recalcitrant", def: "having an obstinately uncooperative attitude toward authority or discipline"),
   Word(word: "erudite", def: "having or showing great knowledge or learning"),
       Word(word: "equivocate", def: "use ambiguous language so as to conceal the truth or avoid committing oneself")]),
 List(title: "Favorite Words", words: [
   Word(word: "revanchism", def: "a policy of seeking to retaliate, especially to recover lost territory"),
   Word(word: "unction", def: "an excessive, affected, sometimes cloying earnestness or fervor in manner, especially in speaking."),
   Word(word: "misanthrope", def: "a person who dislikes humankind and avoids human society"),
   Word(word: "obdurate", def: "stubbornly refusing to change one's opinion or course of action"),
   Word(word: "impetuous", def: "acting or done quickly and without thought or care")]),
]*/


import UIKit
import CoreData
class ListCollectionController : UICollectionViewController {
    
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    }()
    var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var addedView: UIView!
    @IBOutlet var listNameTF: UITextField!
    @IBOutlet var plusButton: UIButton!
    var favoriteLists: [List] = [];
    override func viewDidLoad() {
        super.viewDidLoad();
        addedView.layer.cornerRadius = 10;

        let fetchRequest = NSFetchRequest<List>(entityName: "List")
        
        do {
            self.favoriteLists = try self.context.fetch(fetchRequest);
        } catch let error {
            print ("error fetching words: \(error)")
        }
        let layout = self.collectionViewLayout();
        self.collectionView.collectionViewLayout = layout;
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(tapRecognizer:)));
        tapRecognizer.delegate = self
        self.navigationController!.view.addGestureRecognizer(tapRecognizer);
        tapRecognizer.isEnabled = false;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        collectionView.reloadData()
    }
}
extension ListCollectionController : UIGestureRecognizerDelegate {
    @objc func handleTap(tapRecognizer: UITapGestureRecognizer) {
        tapRecognizer.isEnabled = false;
        listNameTF.text = "";
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 12, options: .curveEaseOut) {
            self.addedView.alpha = 0;
            self.addedView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        } completion: { _ in
            self.addedView.removeFromSuperview();

        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let view = touch.view;
        if (view != self.addedView) {
            return true;
        }
        return false;
    }
} //tap recognizer
extension ListCollectionController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteLists.count;
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ListCell;
        cell.titleLabel.text = favoriteLists[indexPath.row].title;
        let numwords = favoriteLists[indexPath.row].words?.count ?? 0
        if (numwords == 1) {
            cell.numWordsLabel.text = "1 word";
        } else {
            cell.numWordsLabel.text = "\(numwords) words"
        }
        cell.layer.cornerRadius = 10;
        return cell;
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemAt indexPath: IndexPath,
                                 point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let duplicateAction = self.duplicateAction(indexPath)
            let deleteAction = self.deleteAction(indexPath)
            return UIMenu(title: "", children: [duplicateAction, deleteAction])
        }
    }
    
    func duplicateAction(_ indexPath: IndexPath) -> UIAction {
        return UIAction(title: NSLocalizedString("Duplicate", comment: ""),
                        image: UIImage(systemName: "plus.square.on.square")) { action in
            let list = self.favoriteLists[indexPath.row];
            do {
                let duplicate = List(context: self.context);
                duplicate.title = list.title;
                duplicate.words = list.words;
                self.context.insert(duplicate)
                try self.context.save();
                self.favoriteLists.insert(duplicate, at: 0)
                self.collectionView.reloadData()
            } catch let error {
                print ("error duplicating list: \(error)")
            }
            //self.performDuplicate(indexPath);
        }
    }
    func deleteAction(_ indexPath: IndexPath) -> UIAction {
        return UIAction(title: NSLocalizedString("Delete", comment: ""),
                        image: UIImage(systemName: "arrow.up.square")) { action in
            let list = self.favoriteLists[indexPath.row];
            do {
                self.context.delete(list)
                try self.context.save();
                self.favoriteLists.remove(at: indexPath.row);
                self.collectionView.deleteItems(at: [indexPath]);
            } catch let error {
                print("error deleting list: \(error)");
            }
            //self.performDelete(indexPath);
        }
    }
} //initialize
extension ListCollectionController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!;
        let list = self.favoriteLists[selectedIndexPath.row];
        
        let listDetailTableController = segue.destination as! ListDetailTableController;
        listDetailTableController.list = list;
    }
} //segue
extension ListCollectionController {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1));
        let item = NSCollectionLayoutItem(layoutSize: layoutSize);
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10);
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(140));
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item]);
        let section = NSCollectionLayoutSection(group: group);
        let layout = UICollectionViewCompositionalLayout(section: section);
        return layout;
    }
} //layout
extension ListCollectionController {
    @IBAction func addListButton() {
        addedView.center = CGPoint(x: self.collectionView.bounds.width / 2, y: self.collectionView.bounds.height / 3);
        addedView.alpha = 0
        addedView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3);
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 12, options: .curveEaseOut) {
            self.addedView.alpha = 1;
            self.addedView.transform = CGAffineTransform.identity;
        } completion: { _ in
            
        }
        collectionView.addSubview(addedView);
        tapRecognizer.isEnabled = true;
    }
    @IBAction func saveNewList() {
        let newList = List(context: self.context);
        let listName = listNameTF.text;
        newList.title = listName;
        do {
            try self.context.save();
        } catch let error {
            print ("error saving context: \(error)");
        }

        newList.words = [];
        
        favoriteLists.insert(newList, at: 0);
        
        let newIndexPath = IndexPath(item: 0, section: 0);
        collectionView.insertItems(at: [newIndexPath])
        collectionView.reloadData();
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 12, options: .curveEaseOut) {
            self.addedView.alpha = 0;
            self.addedView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        } completion: { _ in
            self.addedView.removeFromSuperview();

        }
        listNameTF.text = "";
    }
} //create new list
extension ListCollectionController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textRange = Range(range, in: textField.text!)!;
        let updatedText = textField.text!.replacingCharacters(in: textRange, with: string);
        if (updatedText != "") {
            plusButton.isEnabled = true;
        } else {
            plusButton.isEnabled = false;
        }
        return true;
    }
}
class ListCell : UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numWordsLabel: UILabel!
}

