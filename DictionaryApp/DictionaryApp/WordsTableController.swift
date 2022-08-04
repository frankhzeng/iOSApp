
import UIKit
import CoreData
class WordsTableController: UITableViewController {
    
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        // 1
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        // 2
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Word.word), ascending: true);
        
        fetchRequest.sortDescriptors = [sortDescriptor];
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context, sectionNameKeyPath: #keyPath(Word.index),
            cacheName: nil)
      return fetchedResultsController
    }()
    let searchController = UISearchController(searchResultsController: nil);

    var isFiltering: Bool {
        return searchController.isActive
    }
    var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var newWordTF: UITextField!
    @IBOutlet var newDefTextView: UITextView!
    @IBOutlet var newWordView: UIView!
    @IBOutlet var plusButton: UIButton!
//    var words: [Word] = []
    var filteredWords: [Word] = [];

}
extension WordsTableController {
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try self.fetchedResultsController.performFetch();
        } catch let error as NSError {
            print ("error fetching with fetched results controller: \(error)")
        }
        
        newDefTextView.layer.cornerRadius = 5;
        searchController.searchBar.autocapitalizationType = .none;
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = false;
        self.definesPresentationContext = true;
        self.navigationItem.searchController = searchController;
        
        
        self.tableView.tableFooterView = UIView()
        self.newWordView.layer.cornerRadius = 10
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(tapRecognizer:)));
        tapRecognizer.delegate = self
        self.navigationController!.view.addGestureRecognizer(tapRecognizer);
        tapRecognizer.isEnabled = false;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.tableView.reloadData();
    }
}
extension WordsTableController : UIGestureRecognizerDelegate {
    @IBAction func addButton() {
        self.newWordView.center = CGPoint(x: self.navigationController!.view.center.x, y: self.navigationController!.view.bounds.height / 3)
        
        self.navigationController!.view.addSubview(self.newWordView);
        self.newWordTF.becomeFirstResponder();
        //tap recognzier
        tapRecognizer.isEnabled = true;
        newWordView.alpha = 0
        newWordView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3);
        self.navigationItem.rightBarButtonItem?.isEnabled = false;
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 12, options: .curveEaseOut) {
            self.newWordView.alpha = 1;
            self.newWordView.transform = CGAffineTransform.identity;
        } completion: { _ in
            
        }
    }
    @IBAction func saveWordTapped() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true;
        if (!(newWordTF.text == "")) {
            let newWord = Word(context: self.context)
            newWord.word = newWordTF.text!
            newWord.def = newDefTextView.text!
            newWord.index = String(newWordTF.text!.first ?? "#")
            //words.append(newWord);
            
            do {
                try self.context.save()
            } catch let error {
                print("error saving: \(error)");
            }
            do {
                try self.fetchedResultsController.performFetch();
            } catch let error as NSError {
                print ("error fetching with fetched results controller: \(error)")
            }
            self.tableView.reloadData();
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 12, options: .curveEaseOut) {
                self.newWordView.alpha = 0;
                self.newWordView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
            } completion: { _ in
                self.newWordView.removeFromSuperview();

            }
            tapRecognizer.isEnabled = false;
            self.newWordTF.text = "";
            self.newDefTextView.text = "";
        }
    }
    @objc func handleTap(tapRecognizer: UITapGestureRecognizer) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true;
        self.newWordTF.text = "";
        self.newDefTextView.text = "";
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 12, options: .curveEaseOut) {
            self.newWordView.alpha = 0;
            self.newWordView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        } completion: { _ in
            self.newWordView.removeFromSuperview();

        }
        tapRecognizer.isEnabled = false;
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let view = touch.view;
        if (view != self.newWordView) {
            return true;
        } else {
            return false;
        }
    }
} //buttons
extension WordsTableController { //load page
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (isFiltering) {
            return 1;
        }
        return self.fetchedResultsController.sections?.count ?? 0;
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering) {
            return filteredWords.count;
            
        }
        guard let sectionInfo = self.fetchedResultsController.sections?[section] else {
            return 0;
        }
        return sectionInfo.numberOfObjects;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordCell;
        

        let word: Word!
        if (isFiltering) {
            word = filteredWords[indexPath.row]
        } else {
            word = fetchedResultsController.object(at: indexPath);
        }
        cell.wordLabel.text = word.word;
        cell.definitionLabel.text = word.def;
        
        return cell;
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let word = self.words.remove(at: indexPath.row);
        
        let word = self.fetchedResultsController.object(at: indexPath);
        self.context.delete(word);
        do {
            try context.save();
        } catch let error {
            print("error deleting from context: \(error)")
        }
        tableView.deleteRows(at:[indexPath], with: .automatic);

        if (tableView.numberOfRows(inSection: indexPath.section) == 1) {
            tableView.deleteSections([indexPath.section], with: .automatic)
        }

        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = self.fetchedResultsController.sections?[section] else {
            return nil;
        }
        return sectionInfo.name;
    }
} //load page
extension WordsTableController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    func filterContentForSearchText(_ searchText: String) {
        self.filteredWords = self.fetchedResultsController.fetchedObjects ?? [].filter { (word: Word) -> Bool in
            (word.word?.lowercased().contains(searchText.lowercased()) ?? false);
        }
        if (searchText == "") {
            filteredWords = self.fetchedResultsController.fetchedObjects ?? [];
        }
        tableView.reloadData()
    }
}
extension WordsTableController : UITextFieldDelegate {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newDefTextView.becomeFirstResponder();
    }
} //text field delegate

extension WordsTableController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = tableView.indexPathForSelectedRow!
        let wordDetailController = segue.destination as! WordDetailController;
        if (isFiltering) {
            wordDetailController.word = filteredWords[selectedIndexPath.row]
        } else {
            wordDetailController.word = self.fetchedResultsController.object(at: selectedIndexPath);
        }
    }
}

extension WordsTableController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "enter definition...") {
            textView.text = "";
        }
    }
}
class WordCell : UITableViewCell {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var definitionLabel: UILabel!
}
