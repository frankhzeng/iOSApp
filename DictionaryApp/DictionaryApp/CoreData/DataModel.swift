
import Foundation


//class Word : Equatable {
//    static func ==(lhs: Word, rhs: Word) -> Bool {
//        return lhs.word == rhs.word;
//    }
//    var word: String;
//    var def: String;
//    init(word: String, def: String) {
//        self.word = word;
//        self.def = def;
//    }
//}
//
//class List {
//    var title: String;
//    var words: [Word];
//    init(title: String, words: [Word]) {
//        self.title = title;
//        self.words = words;
//    }
//}

class Quiz {
     //don't use outside of here
    
    var questions: [QuizQuestion] = []
    init(NS_List: List) {
        //generate order
        let list = NS_List.words?.allObjects as! [Word]
        var order: [Int] = [];

        for i in 0...list.count - 1 {
            order.append(i);
        }
        order.shuffle();
        //generate first other def
        for i in order {
            var firstAltDef = Int.random(in: 0...list.count - 1);
            while (firstAltDef == i) {
                firstAltDef = Int.random(in: 0...list.count - 1);
            }
            var secAltDef = Int.random(in: 0...list.count - 1);
            while (secAltDef == i || secAltDef == firstAltDef) {
                secAltDef = Int.random(in: 0...list.count - 1);
            }

            //generate correct answer index
            var firstAnswer: String;
            var secondAnswer: String;
            var thirdAnswer: String;
            let index = Int.random(in: 1...3);

            switch(index) {
                case 1:
                    firstAnswer = list[i].def!;
                    secondAnswer = list[firstAltDef].def!
                    thirdAnswer = list[secAltDef].def!
                case 2:
                    firstAnswer = list[firstAltDef].def!
                    secondAnswer = list[i].def!
                    thirdAnswer = list[secAltDef].def!
                case 3:
                    firstAnswer = list[firstAltDef].def!
                    secondAnswer = list[secAltDef].def!
                    thirdAnswer = list[i].def!
                default:
                    fatalError("something went wrong");
            }
            questions.append(QuizQuestion(word: list[i], answerA: firstAnswer, answerB: secondAnswer, answerC: thirdAnswer, correctAnswer: index))
        }
    }
}

class QuizQuestion {
    var word: Word
    var answerA: String;
    var answerB: String;
    var answerC: String;
    var correctAnswer: Int;
    
    init(word: Word, answerA: String, answerB: String, answerC: String, correctAnswer: Int) {
        self.word = word;
        self.answerA = answerA;
        self.answerB = answerB;
        self.answerC = answerC;
        self.correctAnswer = correctAnswer;
    }
}


/*
 get random word from List
 get 2 other random words from List, find the .def, and make the answers those
 get random int 1..3
 if (1) answerA = correct answer
 if (2) answerB = correctANswer
 
 */
