
import UIKit


protocol EditWordDelegate: AnyObject {
    func doneEditingWord()
}
class EditWordController : UIViewController {
    var word: Word!
    weak var delegate: EditWordDelegate!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var defTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = word.word;
        defTextView.text = word.def;
    }
    
    @IBAction func saveButtonPressed() {
        //dismiss view and save the edited info
        self.dismiss(animated: true);
        word.def = defTextView.text;
        if (nameTextField.text != "") {
            word.word = nameTextField.text!;
        }
        self.delegate.doneEditingWord()

    }
}

extension EditWordController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textRange = Range(range, in: textField.text!)!;
        let updatedText = textField.text!.replacingCharacters(in: textRange, with: string);
        if (updatedText != "") {
            saveButton.isEnabled = true;
        } else {
            saveButton.isEnabled = false;
        }
        return true;
    }
}
