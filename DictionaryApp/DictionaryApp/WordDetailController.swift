
import UIKit

class WordDetailController : UIViewController {
    var word: Word!
    @IBOutlet var nameTextField: UILabel!
    @IBOutlet var defTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = word.word;
        defTextView.text = word.def;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        nameTextField.text = word.word;
        defTextView.text = word.def;
    }
}

extension WordDetailController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editWordController = segue.destination as! EditWordController;
        editWordController.word = word;
        editWordController.delegate = self;
    }
}
extension WordDetailController : EditWordDelegate {
    func doneEditingWord() {
        self.defTextView.text = word.def;
        self.nameTextField.text = word.word;
    }
}
