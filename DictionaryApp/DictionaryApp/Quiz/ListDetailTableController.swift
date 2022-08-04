
import UIKit
import CoreData
class ListDetailTableController : UITableViewController {
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    }()
    var list: List!
    var words: [Word] = [];
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = list.title;
        self.words = list.words?.allObjects as! [Word]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        self.tableView.reloadData();
    }
}

extension ListDetailTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath);
        
        let word = self.words[indexPath.row];
        cell.textLabel?.text = word.word;
        cell.detailTextLabel?.text = word.def;
        return cell;
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let word = self.words.remove(at: indexPath.row);
        self.list.removeFromWords(word)
        do {
            try self.context.save();
        } catch let error {
            print ("error deleting from listdetail controller: \(error)")
        }
        tableView.deleteRows(at:[indexPath], with: .automatic);
    }
}
extension ListDetailTableController : WordSelectorDelegate {
    func wordSelectorDidAddWords(words: [Word]) {
//        let mutableWords = self.list.words?.mutableCopy() as? NSMutableSet
//        for word in words {
//            mutableWords?.add(word)
//        }
        
        for word in words {
            list.addToWords(word);
        }
        //list.words = mutableWords;
        self.words = list.words?.allObjects as! [Word]
        do {
            try self.context.save();
        } catch let error {
            print ("error adding to list: \(error)")
        }
        print(words);
        self.tableView.reloadData()
    }
}
extension ListDetailTableController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowWordDetails") {
            let index = tableView.indexPathForSelectedRow!
            let wordDetailController = segue.destination as! WordDetailController;
            wordDetailController.word = words[index.row];
        }
        if (segue.identifier == "SelectWords") {
            let wordSelectorController = segue.destination as! WordSelectorController
            wordSelectorController.delegate = self;
        }
    }
}
