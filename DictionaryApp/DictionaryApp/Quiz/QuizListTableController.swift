import UIKit
import CoreData
class QuizListTableController : UITableViewController{
    var favoriteLists: [List] = []
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    }()
    override func viewDidLoad() {
        super.viewDidLoad();
        let fetchRequest = NSFetchRequest<List>(entityName: "List");
        do { //access only
            self.favoriteLists = try self.context.fetch(fetchRequest);
        } catch let error {
            print ("error fetching quiz list: \(error)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.tableView.reloadData()
    }
}


extension QuizListTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteLists.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currList = favoriteLists[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectListCell", for: indexPath);
        cell.textLabel?.text = currList.title;
        let wordnum = (currList.words!.count)
        if (wordnum == 1) {
            cell.detailTextLabel?.text = "1 word";
        } else {
            cell.detailTextLabel?.text = "\(wordnum) words";

        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = self.favoriteLists[indexPath.row];
        if list.words?.count ?? 0 < 3 {
            //alert user
            let alert = UIAlertController(title: "Error", message: "You need at least 3 words in this list to quiz yourself.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add More Words", comment: "to word selector"), style: .default, handler: { _ in
                self.performSegue(withIdentifier: "ErrorSelector", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "StartQuiz", sender: nil)
        }
    }
}
extension QuizListTableController : WordSelectorDelegate {
    func wordSelectorDidAddNewWords(words: [Word], toList list: List) {
        for word in words {
            list.addToWords(word);
        }
        print (words);
        print (list);
        do {
            try self.context.save();
            self.tableView.reloadData()
        } catch let error {
            print ("error saving context from selector controller: \(error)")
        }
    }
}
extension QuizListTableController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let list = favoriteLists[tableView.indexPathForSelectedRow!.row];
        if (segue.identifier == "StartQuiz") {
            let quizController = segue.destination as! QuizController;
            quizController.quiz = Quiz(NS_List: list);
        } else {
            let wordSelectorController = segue.destination as! WordSelectorController;
            wordSelectorController.delegate = self;
            wordSelectorController.list = list;
        }
    }
}
