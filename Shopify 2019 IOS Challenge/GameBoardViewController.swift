//
//  GameBoardViewController.swift
//  Shopify 2019 IOS Challenge
//
//  Created by Alexandre Attar on 2019-05-04.
//  Copyright © 2019 AADevelopment. All rights reserved.
//

import Foundation
import UIKit

enum Direction: UInt32 {
    case Up
    case Down
    case Right
    case Left
    case Diagonal
    
    static func random() -> Direction {
        // Update as new enumerations are added
        let maxValue = Diagonal.rawValue
        
        let rand = arc4random_uniform(maxValue+1)
        return Direction(rawValue: rand)!
    }
}

class GameBoardViewController: UIViewController, UIGestureRecognizerDelegate  {
    @IBOutlet weak var searchWords: UICollectionView!
    @IBOutlet weak var gameBoard: UICollectionView!
    @IBOutlet weak var gameBoardHeight: NSLayoutConstraint!
    @IBOutlet weak var searchWordsHeight: NSLayoutConstraint!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var panGesture  = UIPanGestureRecognizer()
    var startCoordinates:IndexPath?
    var endCoordinates:IndexPath?
    var selectedCell: UIView?
    var seconds = 30
    
    //Game setup variable
    private let gridSize:Int = ViewController.globalVariable.gridSize
    private let timerOn:Bool = ViewController.globalVariable.timer
    private let hideWordsOn:Bool = ViewController.globalVariable.hideWords
    var gameOver:Bool = false {
        didSet{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = score < words.count ? storyboard.instantiateViewController(withIdentifier: "loseModal") : storyboard.instantiateViewController(withIdentifier: "winModal")
            controller.modalPresentationStyle = .overCurrentContext
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    var score:Int = 0
    var words = ["SWIFT", "JAVA", "KOTLIN", "OBJECTIVEC", "VARIABLE", "MOBILE", "REACT", "PHP", "IPHONE", "APPLE"]
    var copyArray: [String]?
    lazy var gameBoardValues = [[String]](repeating: [String](repeating: "?", count: gridSize), count: gridSize)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateGameBoardArray(with: words)
        searchWords.layer.borderWidth = 1
        searchWords.layer.cornerRadius = 20
        searchWords.layer.borderColor = UIColor.clear.cgColor
        
        
        gameTimer(endGame: gameOver)
        
        gameBoard.layer.borderWidth = 1
        gameBoard.layer.cornerRadius = 10
        gameBoard.layer.borderColor = UIColor.clear.cgColor
        
        //Adding pan gesture to track the 'gesture on the gameboard'
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(touchGestureBoard(_:)))
        gameBoard.isUserInteractionEnabled = true
        gameBoard.addGestureRecognizer(panGesture)
        
        //copy our array for our touchGestureBoard function where
        //we will use it to track index of elements of original of array
        //while we remote elements fromt the main array 'words'
        copyArray = words
    }
    
}

//##########################################################
// Extnsions of the different protocols below to clean up the main viewController above
//##########################################################


extension GameBoardViewController: UICollectionViewDataSource {
    //We are using Squared Grids therefore single 'size' value is enough in our case
    //Since we know the size of the grid and we can pass the word we one add to our game
    //Will return a random indexPath of the possible starting coordinates for the given word
    func randomStartingIndexToPopulateGrid(ofSize grid: Int, forWord count: Int, to direction: Direction) -> IndexPath {
        var numberX:Int
        var numberY:Int
        
        switch (direction){
        case .Left:
            if (count == grid) {
                numberX = grid - 1
            } else {
               numberX = Int.random(in: count ..< grid)
            }
            numberY = Int.random(in: 0 ..< grid)
            return [numberX, numberY]
        case .Right:
            if (count == grid) {
                numberX = 0
            } else {
                numberX = Int.random(in: 0 ..< (grid - count))
            }
            numberY = Int.random(in: 0 ..< grid)
            return [numberX, numberY]
        case .Up:
            if (count == grid) {
                numberY = grid - 1
            } else {
                numberY = Int.random(in: count ..< grid)
            }
            numberX = Int.random(in: 0 ..< (grid))
            return [numberX, numberY]
        case .Down:
            if (count == grid) {
                numberY = 0
            } else {
                numberY = Int.random(in: 0 ..< (grid - count))
            }
            numberX = Int.random(in: 0 ..< grid)
            return [numberX, numberY]
        case .Diagonal:
            if (count == grid) {
                numberX = 0
                numberY = 0
            } else {
                numberX = Int.random(in: 0 ..< (grid - count))
                numberY = Int.random(in: 0 ..< (grid - count))
            }
            return [numberX, numberY]
        }
    }
    
    func randomLetter() -> String {
        guard let uppercaseLetters = ((65...90).map {String(UnicodeScalar($0))}).randomElement() else { return "" }
        return uppercaseLetters
    }
    
    //For Safe Measure use function to verify if it's possible to populate the collection cell for 'word' into 'direction' from 'index'
    //We have to revers X & Y Coordinates for the array because of the way we populate the collectionViewCell ( section by section)
    //If array is not "?" but the letter at that position is the same as we need to insert return true
    func verifyGameBoardCells(for word: String, from index: IndexPath, to direction: Direction, for gameBoardValues: [[String]]) -> Bool{
        let characters = Array(word)
        var canAddValues = false
        let positionX = index.section
        let positionY = index.row
        for (index, char) in characters.enumerated() {
            if (direction == .Right){
                if (gameBoardValues[positionX+index][positionY] == "?" || gameBoardValues[positionX][positionY] == String(char)) {
                    canAddValues = true
                } else {
                    canAddValues = false
                    break
                }
            } else if(direction == .Left){
                if (gameBoardValues[positionX-index][positionY] == "?" || gameBoardValues[positionX][positionY] == String(char)) {
                    canAddValues = true
                } else {
                    canAddValues = false
                    break
                }
            } else if(direction == .Up){
                if (gameBoardValues[positionX][positionY-index] == "?" || gameBoardValues[positionX][positionY] == String(char)) {
                    canAddValues = true
                } else {
                    canAddValues = false
                    break
                }
            } else if(direction == .Down){
                if (gameBoardValues[positionX][positionY+index] == "?" || gameBoardValues[positionX][positionY] == String(char)) {
                    canAddValues = true
                } else {
                    canAddValues = false
                    break
                }
            } else if(direction == .Diagonal){
                if (gameBoardValues[positionX+index][positionY+index] == "?" || gameBoardValues[positionX][positionY] == String(char)) {
                    canAddValues = true
                } else {
                    canAddValues = false
                    break
                }
            }
        }
        return canAddValues
    }
    
    //We Populate the board with our the values from our gameBoardValues
    func populateGameBoardArray(with words: [String]){
        for word in words {
            var direction = Direction.random()
            var startingIndex = randomStartingIndexToPopulateGrid(ofSize: gridSize, forWord: word.count, to: direction)
            var canBeAdded = verifyGameBoardCells(for: word, from: startingIndex, to: direction, for: gameBoardValues)
            var addedSuccesfully = false
            
            while (!addedSuccesfully){
                if (canBeAdded){
                    let positionX = Int(startingIndex.section)
                    let positionY = Int(startingIndex.row)
                    let characters = Array(word)
                    for (index, char) in characters.enumerated() {
                        if(direction == .Left) {
                            gameBoardValues[positionX-index][positionY] = String(char)
                        } else if (direction == .Right) {
                            gameBoardValues[positionX+index][positionY] = String(char)
                        } else if (direction == .Up) {
                            gameBoardValues[positionX][positionY-index] = String(char)
                        } else if (direction == .Down) {
                            gameBoardValues[positionX][positionY+index] = String(char)
                        } else {
                            gameBoardValues[positionX+index][positionY+index] = String(char)
                        }
                    }
                    addedSuccesfully = true
                } else {
                    direction = Direction.random()
                    startingIndex = randomStartingIndexToPopulateGrid(ofSize: gridSize, forWord: word.count, to: direction)
                    canBeAdded = verifyGameBoardCells(for: word, from: startingIndex, to: direction, for: self.gameBoardValues)
                }
            }
        }
    }
}

extension GameBoardViewController: UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(collectionView == self.searchWords) {
            return 1
        } else {
            return gridSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.searchWords) {
            return words.count
        } else {
            return gridSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == self.gameBoard) {
            return 0.0
        }
        return CGFloat(gridSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.searchWords) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wordCell", for: indexPath) as? WordsCell else {
                return UICollectionViewCell()
            }
            searchWordsHeight.constant = searchWords.contentSize.height
            cell.backgroundColor = UIColor.clear
            cell.wordLabel.text = words[indexPath.item]
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letterCell", for: indexPath) as? LettersCell else {
                return UICollectionViewCell()
            }
            gameBoardHeight.constant = gameBoard.contentSize.height
            cell.backgroundColor = UIColor.clear
            //Populate cell with array Letter anr fill cells for "?" with random letters
            if (gameBoardValues[indexPath.section][indexPath.row] == "?") {
                cell.lettersLabel.text = randomLetter()
            } else {
                cell.lettersLabel.text = gameBoardValues[indexPath.section][indexPath.row]
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == self.searchWords) {
            //Get the width of each work of our array to set as size of our cell
            let size: CGSize = words[indexPath.row].size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
            
            let cellWidth:CGFloat = size.width + 5
            let cellHeight:CGFloat = size.height + 10
            
            return CGSize(width: cellWidth, height: cellHeight)
        } else {
            let cellSize = (self.gameBoard.layer.bounds.width)/CGFloat(gridSize)
            return CGSize(width: cellSize, height: cellSize)
        }
    }
}

private extension GameBoardViewController {
    
    func gameTimer(endGame:Bool = false ) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.seconds -= 1
            self.timerLabel.text? = "00:\(self.seconds)"
            if (self.seconds <= 0){
                timer.invalidate()
                self.gameOver = true
            }
        })
        if endGame {
            timer.invalidate()
        } else {
            timer.fire()
        }
    }
    
    func verifyGuessedWord(startingIndexPath: IndexPath, endindIndexPath: IndexPath) -> String{
        let positionX = startingIndexPath.section
        let positionY = startingIndexPath.row
        var guessWord: String = ""
        
        //DIRECTION: .DIAGONAL
        if(startingIndexPath.section < endindIndexPath.section && startingIndexPath.row < endindIndexPath.row){
            for i in 0...(endindIndexPath.section - startingIndexPath.section) {
                //have to reverse y coordinates and x becsause of the way we indexed out cells
                let letter = "\(gameBoardValues[positionY+i][positionX+i])"
                guessWord.append(letter)
            }
        }
            //DIRECTION: .UP
        else if(startingIndexPath.row > endindIndexPath.row && startingIndexPath.section == endindIndexPath.section){
            for i in 0...(startingIndexPath.row - endindIndexPath.row) {
                //have to reverse y coordinates and x becsause of the way we indexed out cells
                let letter = "\(gameBoardValues[positionY-i][positionX])"
                guessWord.append(letter)
            }
        }
            //DIRECTION: .Down
        else if(startingIndexPath.row < endindIndexPath.row && startingIndexPath.section == endindIndexPath.section){
            for i in 0...(endindIndexPath.row - startingIndexPath.row) {
                //have to reverse y coordinates and x becsause of the way we indexed out cells
                let letter = "\(gameBoardValues[positionY+i][positionX])"
                guessWord.append(letter)
            }
        }
            //DIRECTION: .Left
        else if(startingIndexPath.section > endindIndexPath.section && startingIndexPath.row == endindIndexPath.row){
            for i in 0...(startingIndexPath.section - endindIndexPath.section) {
                let letter = "\(gameBoardValues[positionY][positionX-i])"
                guessWord.append(letter)
            }
        }
            //DIRECTION: .Right
        else if(startingIndexPath.section < endindIndexPath.section && startingIndexPath.row == endindIndexPath.row){
            for i in 0...(endindIndexPath.section - startingIndexPath.section) {
                let letter = "\(gameBoardValues[positionY][positionX+i])"
                guessWord.append(letter)
            }
        }
        
        return guessWord
    }
    
    //#selector Function for locating which letter we touch
    //Get the size of our board devided by the size the number of cell (The grid size selected on main menu)
    @objc func touchGestureBoard(_ sender:UIPanGestureRecognizer) {
        let location = sender.location(in: gameBoard)
        let cellSize = (gameBoard.contentSize.width)/CGFloat(gridSize)
        // coordinates of lettersCells IndexPath
        let x = Int(location.x/cellSize)
        let y = Int(location.y/cellSize)
        
        if sender.state == .began {
            startCoordinates = [x, y]
        }
        
        if sender.state == .ended {
            endCoordinates = [x, y]
            let guessWord = verifyGuessedWord(startingIndexPath: startCoordinates!, endindIndexPath: endCoordinates!)
            if words.contains(guessWord) {
                gameBoard.drawLineFrom(from: [startCoordinates!.row, startCoordinates!.section], to: [endCoordinates!.row, endCoordinates!.section])
                guard let wordFoundIndex = words.firstIndex(of: guessWord) else { return }
                
                //Since we are removing elements from the array the index of the items will change
                guard let indexPathFromArray = copyArray?.firstIndex(of: guessWord) else { return }
                guard let wordlist = searchWords.cellForItem(at: [0,indexPathFromArray]) as? WordsCell else { return }
                wordlist.wordLabel.textColor = .lightGray
                
                //We remove found words from array to prevent guessing them again
                words.remove(at: wordFoundIndex)
                score+=1
                scoreLabel.text? = "\(score)"
                //if on timeAttack mode
                if (timerOn) {
                    seconds += 10
                    
                    //TODO = replace 12 by different color, animate? presentation
                    timerLabel.text? = "\(timerLabel.text!) + 10"
                }
                
                //Game Over
                //We compare to the copyArray since we remove words guessed from words array
                if (score == copyArray!.count) {
                    gameOver = true
                    gameTimer(endGame: gameOver)

                }
            }
        }
    }
}

private extension UICollectionView {
    func drawLineFrom(from: IndexPath, to: IndexPath, lineWidth: CGFloat = 2) {
        guard let fromPoint = cellForItem(at: from as IndexPath)?.center, let toPoint = cellForItem(at: to as IndexPath)?.center else {
            return
        }
        
        let path = UIBezierPath()
        let color: UIColor = UIColor.random()
        
        path.move(to: convert(fromPoint, to: self))
        path.addLine(to: convert(toPoint, to: self))
        
        
        let layer = CAShapeLayer()
        
        layer.path = path.cgPath
        layer.lineWidth = (self.cellForItem(at: from)?.contentView.frame.height)! - 10
        layer.lineCap = .round
        layer.strokeColor = color.cgColor
    
        layer.cornerRadius = (self.cellForItem(at: from)?.contentView.frame.height)!/2
        layer.opacity = 0.4
        
        self.layer.addSublayer(layer)
    }
}

private extension UIColor {
    //returns random color values
    static func random() -> UIColor {
        return UIColor(red:   .random(), green: .random(), blue:  .random(), alpha: 1.0)
    }
}

private extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UILabel {
    func addTimeTextColor(fullText: String , changeText: String) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        self.attributedText = attribute
    }
}
