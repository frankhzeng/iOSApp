import CoreData
import UIKit
@objc protocol WordSelectorDelegate: AnyObject {
    @objc optional func wordSelectorDidAddWords(words: [Word]);
    @objc optional func wordSelectorDidAddNewWords(words: [Word], toList list: List);
}

class WordSelectorController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    }()

    weak var delegate: WordSelectorDelegate!
    var list: List?
    @IBOutlet var tableView: UITableView!
    var words: [Word] = []
    var chosenWords: [Word] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        //let mutableList: NSMutableSet = list.mutableCopy() as! NSMutableSet;
        
        do {
            self.words = try self.context.fetch(fetchRequest);
        } catch let error {
            print ("error fetching words: \(error)")
        }
    }
}

extension WordSelectorController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1;
        } else {
            return words.count;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewWordCell", for: indexPath) as! NewWordCell;
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectorWordCell", for: indexPath) as! SelectorWordCell;
            let word = words[indexPath.row];
            cell.wordLabel.text = word.word;
            
            if (self.chosenWords.contains(word)) {
                cell.selectorButton.setBackgroundImage(UIImage(systemName: "record.circle"), for: .normal)
            } else {
                cell.selectorButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            }
            
            return cell;
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = words[indexPath.row];
        if (indexPath.section == 0) {
            return;
        }
        if (self.chosenWords.contains(word)) {
            let index = chosenWords.firstIndex(of: word)!;
            chosenWords.remove(at: index);
        } else {
            chosenWords.insert(word, at: 0)
        }
        tableView.reloadData()
    }
}
extension WordSelectorController {
    @IBAction func doneButtonPressed() {

        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NewWordCell;
        let cword = cell.nameTextField.text;
        if (cword != "") {
            let newWord = Word(context: self.context);
            newWord.word = cword!
            newWord.def = cell.defTextView.text;
            chosenWords.append(newWord);
            context.insert(newWord);
            do {
                try self.context.save()
            } catch let error {
                print("error saving new selector word to context: \(error)")
            }
        }
        if let list = list {
            self.delegate.wordSelectorDidAddNewWords?(words: self.chosenWords, toList: list)

        } else {
            self.delegate.wordSelectorDidAddWords?(words: self.chosenWords);
        }
        self.dismiss(animated: true, completion: nil);
        
    }
}
extension WordSelectorController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == "enter a definition...") {
            textView.text = "";
        }
    }
    
}

class SelectorWordCell : UITableViewCell {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var selectorButton: UIButton!
}
class NewWordCell : UITableViewCell {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var defTextView: UITextView!
}
