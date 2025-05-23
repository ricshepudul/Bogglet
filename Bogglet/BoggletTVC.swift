//
//  BoggletTVC.swift
//  Bogglet
//
//  Created by HPro2 on 9/18/24.
//

import UIKit

//I DID 1, 2, 3, 4, 5, 7, 9
class BoggletTVC: UITableViewController {
    
    var words = [String]()
    var word = -1
    var correctAnswers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(getAnswer))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(nextWord))
        
        if let filePath = Bundle.main.path(forResource: "words", ofType: "txt") {
            if let fileContents = try? String(contentsOfFile: filePath, encoding: .utf16) {
                words = fileContents.components(separatedBy: "\n")
            } else {
                loadDefaultWords()
            }
        } else {
                words = ["succeeds"]
                loadDefaultWords()
        }
        words.shuffle()
        startGame()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return correctAnswers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = correctAnswers[indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Custom Functions
    
    func startGame() {
        correctAnswers.removeAll()
        tableView.reloadData()
        word += 1
        title = words[word]
    }
    
    func restartGame(action: UIAlertAction) {
        correctAnswers.removeAll()
        tableView.reloadData()
        word += 1
        title = words[word]
    }

    @objc func getAnswer() {
        let ac = UIAlertController(title: "Enter Guess", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitButton = UIAlertAction(title: "Submit", style: .default) {
            [unowned self, ac] (action: UIAlertAction) in
            let answerTextField = ac.textFields![0]
            submit(guess: answerTextField.text!)
        }
        ac.addAction(submitButton)
        present(ac, animated: true)
    }
    
    @objc func nextWord() {
        word += 1
        startGame()
    }
    
    func submit(guess: String) {
        let lowercaseGuess = guess.lowercased()
        if lowercaseGuess != words[word] {
            if real(guess: lowercaseGuess) {
                if original(guess: lowercaseGuess) {
                    if possible(guess: lowercaseGuess) {
                        //yay!
                        if !lowercaseGuess.isEmpty {
                            correctAnswers.insert(lowercaseGuess, at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            if correctAnswers.count >= 10 {
                                let ac = UIAlertController(title:  "You Win!", message: "You got 10 correct answers.", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: restartGame))
                                present(ac, animated: true)
                            }
                        }
                    } else {
                        showErrorMessage(errorMessage: "Please enter a word that contains only letters from the given word. ", errorTitle: "Impossible Word")
                    }
                } else {
                    showErrorMessage(errorMessage: "Please enter a word that has not been guessed yet. ", errorTitle: "Unoriginal Word")
                    
                }
            } else {
                showErrorMessage(errorMessage: "Please enter a valid word. ", errorTitle: "Invalid Word")
            }
        } else {
            showErrorMessage(errorMessage: "Please do not enter the original word. ", errorTitle: "Original Word")
        }
    }

    func real(guess: String) -> Bool {
        if guess.count == 1 {
            if guess == "i" || guess == "a" {
                return true
            } else {
                return false
            }
        }
        let textChecker = UITextChecker()
        let range = NSMakeRange(0, guess.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: guess, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func original(guess: String) -> Bool {
        return !correctAnswers.contains(guess)
    }
    
    func possible(guess: String) -> Bool {
        var letters: [String] = []
        for char in words[word] {
            letters.append(String(char))
        }
        print(letters)
        
        for char in guess {
            if letters.contains(String(char)) {
                for index in 0..<letters.count {
                    if letters[index] == String(char) {
                        letters.remove(at: index)
                        break
                    }
                }
            } else {
                return false
            }
        }
        return true
    }
    
    func showErrorMessage(errorMessage: String, errorTitle: String) {
        let ac = UIAlertController(title:  errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func loadDefaultWords() {
        words = ["defaults", "cringing", "tsarists", "uncommon", "zucchini", "horizons", "intrigue", "obstacle", "shambles", "trespass"]
    }

}


