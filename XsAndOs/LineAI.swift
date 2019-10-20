//
//  LineAI.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/1/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class LineAI {
    
    //MARK: - PROPERTIES
    
    fileprivate var openSteps = [ShortestPathStep]()
    fileprivate var closedSteps = [ShortestPathStep]()
    var grid : Array2D<Node>
    var pathFound = false
    var rows: Int {
        return grid.rows
    }
    var columns: Int{
        return grid.columns
    }
    var pathTeam : Board.UserTeam
    var team: String {
        if pathTeam == .X{
            return x
        }else{
            return o
        }
    }
    var otherTeam: String {
        if pathTeam == .X{
            return o
        }else{
            return x
        }
    }
    var difficulty : Difficulty
    
    //MARK: - INIT
    init(grid: Array2D<Node>, difficulty: Difficulty, userTeam: Board.UserTeam){
        self.grid = grid
        self.difficulty = difficulty
        pathTeam = userTeam
    }
    //MARK: - AI SHORT PATH
    func calculateAIMove() -> (Coordinate?, Node?) {
        let shortestPathsUser = calculatePlayerShortPaths() //fetch the shortest paths for the user
     
        let shortestPathsAI = calculateAIShortPaths() //fetch shortest paths for AI player "o"
        
        switch difficulty{
        case .easy:
            if let stepToDraw = intersectingShortPath(shortPathsUser: shortestPathsUser, shortPathsAI: shortestPathsAI, difficulty: .easy){
                return stepToCoordinateAndNode(stepToDraw)
            }else{
                return randomShortPathToCoordinateAndNode(shortestPathsAI[0])
            }
            
        case .moderate:
            if let stepToDraw = intersectingShortPath(shortPathsUser: shortestPathsUser, shortPathsAI: shortestPathsAI, difficulty: .moderate){
                return stepToCoordinateAndNode(stepToDraw)
            }else{
                return randomShortPathToCoordinateAndNode(shortestPathsAI[0])
            }
            
        case .hard:
            if let stepToDraw = intersectingShortPath(shortPathsUser: shortestPathsUser, shortPathsAI: shortestPathsAI, difficulty: .hard){
                return stepToCoordinateAndNode(stepToDraw)
            }else{
                return randomShortPathToCoordinateAndNode(shortestPathsAI[0])
            }
        }
    }
    
    func intersectingShortPath(shortPathsUser: [ShortPath], shortPathsAI: [ShortPath], difficulty: Difficulty) -> ShortestPathStep?{
        for pathUser in shortPathsUser{
            for pathAI in shortPathsAI{
                for stepUser in pathUser.steps{
                    for stepAI in pathAI.steps{
                        switch difficulty{
                        case .easy:
                            if stepUser.location.column == stepAI.location.column{
                                if let node = nodeFromStep(stepAI){
                                    if node.nodePos.ptWho == ""{
                                        return stepAI
                                    }
                                }
                            }
                        case .moderate:
                            if stepUser.location.column == stepAI.location.column && stepUser.location.row == stepAI.location.row{
                                if let node = nodeFromStep(stepAI){
                                    if node.nodePos.ptWho == ""{
                                        return stepAI
                                    }
                                }
                            }
                        case .hard :
                            if stepUser.location.column == stepAI.location.column && stepUser.location.row == stepAI.location.row{
                                if let node = nodeFromStep(stepAI){
                                    if node.nodePos.ptWho == ""{
                                        return stepAI
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    
    //MARK: - FIND PLAYER SHORT PATH
    func calculatePlayerShortPaths() -> [ShortPath]{
        return lowestPaths()
    }
    
    //MARK: - FIND AI SHORT PATH
    func calculateAIShortPaths() -> [ShortPath]{
        if pathTeam == .X{
            pathTeam = .O
        }else{
            pathTeam = .X
        }
        //switch team mode
        return lowestPaths() //fetch shortest paths for AI player "o"
    }
    
    //MARK: - LOWEST PATHS
    fileprivate func lowestPaths() -> [ShortPath]{
        let shortPaths = calculateAllShortPaths()  //Find every possible short path
        guard shortPaths.count > 0 else {return shortPaths}
        return findPathsWithLowestFScore(shortPaths)//remove all paths but the lowest fScore ones
    }
    
    //MARK: - ALL PATH CALCULATION
    
    fileprivate func calculateAllShortPaths() -> [ShortPath]{
        var shortPaths = [ShortPath]()
        var firstRow = 1
        var lastRow = 1
        
        //Every row finds the shortest path to every row
        repeat {

            var fromNode = grid[1,firstRow]!
            var toNode = grid[columns - 2,lastRow]!
            if pathTeam == .X{
                fromNode = grid[firstRow, 1]!
                toNode = grid[lastRow, rows - 2]!
            }
            guard fromNode.nodeType == .intersection && toNode.nodeType == .intersection else {break}
            let shortPath = calculateShortestPath(fromNode, toNode: toNode)
            if shortPath.steps.count > 0{
                shortPaths.append(shortPath)
            }
            //Move up to next last row
            lastRow += 2
            
            //if all last rows are check, move up to next first row
            if lastRow >= rows - 1{
                lastRow = 1
                firstRow += 2
            }
        }while firstRow <= rows - 1
        return shortPaths
    }
    
    private func findPathsWithLowestFScore(_ shortPaths: [ShortPath]) -> [ShortPath]{
        var shortPaths = shortPaths
        //Sort Paths by fScore
        shortPaths.sort(by: {
            return $0.fScore < $1.fScore
        })
        let lowf = shortPaths[0].fScore
        
        //Create Array with only the lowest fScore
        var shortestPaths = [ShortPath]()
        for path in shortPaths{
            if path.fScore == lowf{
                shortestPaths.append(path)
            }
        }
        shortestPaths.shuffleInPlace()
        return shortestPaths
    }
    
    //MARK: - SINGLE PATH CALCULATION
    
    func calculateShortestPath(_ fromNode: Node, toNode: Node) -> ShortPath{
        var shortestPath = [ShortestPathStep]()
        var shortPath = ShortPath(steps: shortestPath)
    
        // If either intersection is occupied by x then no path
        guard fromNode.nodePos.ptWho != otherTeam else {return shortPath}
        guard toNode.nodePos.ptWho != otherTeam else {return shortPath}
        //Calculate firststep hscore and add to openlist
        let firstStep = ShortestPathStep(node: fromNode)
        let toStep = ShortestPathStep(node: toNode)
        if fromNode.nodePos.ptWho == team{
            firstStep.gScore = -1
        }
        firstStep.hScore = computeHScoreFromLocations(firstStep.location, toLoc: toStep.location)
        insertStepInOpenSteps(firstStep)
        
        repeat{
            // Get the lowest F cost step
            // Because the list is ordered, the first step is always the one with the lowest F cost
            let currentStep = openSteps[0]
            // Add the current step to the closed set
            closedSteps.append(currentStep)

            // Remove it from the open list
            openSteps.remove(at: 0)
            
            // If the currentStep is the desired tile coordinate, we are done!
            if currentStep.location.column == toNode.nodePos.column && currentStep.location.row == toNode.nodePos.row{
                pathFound = true
                shortestPath = constructShortestPath(currentStep)
                shortPath.steps = shortestPath
                break
            }

            // Get the adjacent tiles coord of the current step
            let adjNodes = availableAdjacentSteps(currentStep.location)
            for node in adjNodes{
                let step = ShortestPathStep(node: node)
                if (closedSteps.contains{$0 == step}){
                    continue
                }
                // Compute the cost from the current step to that step
                let moveCost = costToMoveToStep(step)
                step.cost = moveCost
                // Check if the step is already in the open list
                if !(openSteps.contains{$0 == step}){
                    // Set the current step as the parent
                    step.parent = currentStep
                    
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost
                    
                    // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                    step.hScore = computeHScoreFromLocations(step.location, toLoc: toStep.location)
                    
                    // Adding it with the function which is preserving the list ordered by F score
                    insertStepInOpenSteps(step)
                    
                }else{ //already in openlist
                    if let index = openSteps.firstIndex(of: step){
                        let oldStep = openSteps[index]
                        
                        // Check to see if the G score for that step is lower if we use the current step to get there
    
                        if currentStep.gScore + moveCost < oldStep.gScore{
                            // The G score is equal to the parent G score + the cost to move from the parent to it
                            step.gScore = currentStep.gScore + moveCost;
                            
                            // Because the G Score has changed, the F score may have changed too
                            // So to keep the open list ordered we have to remove the step, and re-insert it with
                            // the insert function which is preserving the list ordered by F score
                            
                            // Now we can removing it from the list
                            openSteps.remove(at: index)
                            
                            // Re-insert it with the function which is preserving the list ordered by F score
                            insertStepInOpenSteps(oldStep)
                        }
                    }
                }
            }
        }while openSteps.count > 0
        openSteps.removeAll()
        closedSteps.removeAll()
        if !pathFound { // No path found
            print("no path found")
            return shortPath
        }
        return shortPath
    }
        
    fileprivate func insertStepInOpenSteps(_ step: ShortestPathStep){
        openSteps.append(step)
        openSteps.sort(by: {
            return $0.fScore < $1.fScore
        })
    }
    
    //MARK: - HSCORE METHODS
    // Compute the H score from a position to another (from the current position to the final desired position
    fileprivate func computeHScoreFromLocations(_ fromLoc: Location, toLoc: Location) -> Int{
        let cols = abs((toLoc.column - fromLoc.column)/2)
        var rs = abs(toLoc.row - fromLoc.row)/2
        if abs(toLoc.row - fromLoc.row) % 2 != 0{
            rs += 1
        }
        let h = cols + rs
        return h
        // Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
        // final desired step from the current step, ignoring any obstacles that may be in the way
    }
    
    //MARK STEP COST METHODS
    fileprivate func costToMoveToStep(_ toStep: ShortestPathStep) -> Int{
        
        let node = nodeFromStep(toStep)
        switch pathTeam {
        case .O:
            if node?.nodePos.ptWho == o{
                return 0
            }else{
                return 1
            }
        case .X:
            if node?.nodePos.ptWho == x{
                return 0
            }else{
                return 1
            }
        }
    }
    
    //MARK: - ADJACENT STEP METHODS
    fileprivate func availableAdjacentSteps(_ location: Location) -> [Node]{
        var nodes = [Node]()

        switch pathTeam {
        case .O:
            if location.row % 2 == 0{ //the current step is a vertical line
                nodes = verticalLineAdjNodes(location: location, nodes: nodes)
            }else{ // current step is horizontal
                nodes = horizontalLineAdjNodes(location: location, nodes: nodes)
            }
        case .X:
            if location.row % 2 == 0{ //the current step is a vertical line
                nodes = horizontalLineAdjNodes(location: location, nodes: nodes)
            }else{ // current step is horizontal
                nodes = verticalLineAdjNodes(location: location, nodes: nodes)
            }
        }
        
        return nodes
    }
    
    private func verticalLineAdjNodes(location: Location,nodes: [Node]) -> [Node]{
        var nodes = nodes
        nodes = addNodeToArrayIfValid(column: location.column, row: location.row + 2, nodes: nodes) //top
        nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row + 1, nodes: nodes) //topleft
        nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row - 1, nodes: nodes) //bottomleft
        nodes = addNodeToArrayIfValid(column: location.column, row: location.row - 2, nodes: nodes) //bottom
        nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row + 1, nodes: nodes) //topright
        nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row - 1, nodes: nodes) //bottomright
        return nodes
    }
    
    private func horizontalLineAdjNodes(location: Location,nodes: [Node]) -> [Node]{
        var nodes = nodes
        nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row + 1, nodes: nodes) //topright
        nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row + 1, nodes: nodes) //topleft
        nodes = addNodeToArrayIfValid(column: location.column - 2, row: location.row, nodes: nodes) //left
        nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row - 1, nodes: nodes) //bottomright
        nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row - 1, nodes: nodes) //bottomleft
        nodes = addNodeToArrayIfValid(column: location.column + 2, row: location.row, nodes: nodes) //right
        return nodes
    }
    
    private func addNodeToArrayIfValid(column: Int, row: Int, nodes: [Node]) -> [Node]{
        var nodes = nodes
        if isValidLocation(column: column, row: row){
            if typeAtIntersection(column: column, row: row) == .intersection && grid[column,row]?.nodePos.ptWho != otherTeam{
                nodes.append(grid[column, row]!)
            }
        }
        return nodes
    }
    
    fileprivate func isValidLocation(column: Int, row: Int) -> Bool{
        guard (column >= 0 && column <= columns - 1) else {return false}
        guard(row >= 0 && row <= rows - 1) else {return false}
        return true
    }
    
    //MARK: - OTHER METHODS
    fileprivate func typeAtIntersection(column: Int, row: Int) -> NodeType{
        let node = grid[column, row]
        return (node?.nodeType)!
    }
    
    private func constructShortestPath(_ step: ShortestPathStep?) -> [ShortestPathStep]{
        var step = step
        var steps = [ShortestPathStep]()
        guard step != nil else {return steps}
        repeat{
            steps.insert(step!, at: 0)//add every step at beginning to go from start to finish
            step = step!.parent
        }while step != nil
        
        return steps
        
    }
    
    //MARK: - CONVERSION METHODS
    fileprivate func nodeFromStep(_ step: ShortestPathStep) -> Node?{
        return  grid[step.location.column, step.location.row]
    }
    
    //MARK: - TO COORDINATE AND NODE METHODS
    
    fileprivate func randomShortPathToCoordinateAndNode(_ path: ShortPath) -> (coordinate: Coordinate?, node: Node?){
        var nodeToDraw = Node(column: 0, row: 0, theNodeType: .intersection)
        var stepToDraw = ShortestPathStep(node: nodeToDraw)
        for step in path.steps{
            if let node = nodeFromStep(step){
                if node.nodePos.ptWho == ""{
                    nodeToDraw = node
                    stepToDraw = step
                    break
                }
            }
        }
        return stepToCoordinateAndNode(stepToDraw)
    }

    fileprivate func stepToCoordinateAndNode(_ step: ShortestPathStep) -> (coordinate: Coordinate?, node: Node?){
        
        
        if let node = nodeFromStep(step){
            switch pathTeam{
            case .O:
                if node.nodePos.row! % 2 == 0{ //the current step is a vertical line for O's
                    return (Coordinate(columnA: node.nodePos.column!, rowA: node.nodePos.row! + 1 , columnB: node.nodePos.column!, rowB: node.nodePos.row! - 1, position: nil), node)
                }else{ // horizontal line for O's
                    return (Coordinate(columnA: node.nodePos.column! + 1, rowA: node.nodePos.row! , columnB: node.nodePos.column! - 1, rowB: node.nodePos.row!, position: nil), node)
                }
            case .X:
                if node.nodePos.row! % 2 != 0{ //the current step is a vertical line for X's
                    return (Coordinate(columnA: node.nodePos.column!, rowA: node.nodePos.row! + 1 , columnB: node.nodePos.column!, rowB: node.nodePos.row! - 1, position: nil), node)
                }else{ // horizontal line for O's
                    return (Coordinate(columnA: node.nodePos.column! + 1, rowA: node.nodePos.row! , columnB: node.nodePos.column! - 1, rowB: node.nodePos.row!, position: nil), node)
                }
            }
        }
        return (nil, nil)
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        guard let countInt = count as? Int else { return }
        if countInt < 2 { return }
        
        for i in 0..<countInt - 1 {
            let j = Int(arc4random_uniform(UInt32(countInt - i))) + i
            guard i != j else { continue }
            self.swapAt(i, j)
        }
    }
}

