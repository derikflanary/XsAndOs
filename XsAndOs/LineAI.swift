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
    
    private var openSteps = [ShortestPathStep]()
    private var closedSteps = [ShortestPathStep]()
    var grid : Array2D<Node>
    var pathFound = false
    var rows: Int {
        return grid.rows
    }
    var columns: Int{
        return grid.columns
    }
    
    //MARK: - INIT
    init(grid: Array2D<Node>){
        self.grid = grid
    }
    //MARK: - MAIN FUNCTION
    func calculateAIMove() {
        var shortPaths = calculateAllShortPaths()
        var shortestPaths = findPathsWithLowestFScore(shortPaths)
        
    }
    
//    private func shortPathToCoordinate(path: ShortPath) -> Coordinate{
//        
//    }

    //MARK: - ALL PATH CALCULATION
    
    private func calculateAllShortPaths() -> [ShortPath]{
        var shortPaths = [ShortPath]()
        var firstRow = 1
        var lastRow = 1
        
        //Every row finds the shortest path to every row
        repeat {
            print("firstrow:\(firstRow), lastRow:\(lastRow)")
            let fromNode = grid[1,firstRow]!
            let toNode = grid[columns - 2,lastRow]!
            guard fromNode.nodeType == .Intersection && toNode.nodeType == .Intersection else {break}
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
    
    private func findPathsWithLowestFScore(var shortPaths: [ShortPath]) -> [ShortPath]{
        //Sort Paths by fScore
        shortPaths.sortInPlace({
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
        return shortestPaths
    }
    
    //MARK: - SINGLE PATH CALCULATION
    
    func calculateShortestPath(fromNode: Node, toNode: Node) -> ShortPath{
        var shortestPath = [ShortestPathStep]()
        var shortPath = ShortPath(steps: shortestPath)
        let firstStep = ShortestPathStep(node: fromNode)
        let toStep = ShortestPathStep(node: toNode)
        firstStep.hScore = computeHScoreFromLocations(firstStep.location, toLoc: toStep.location)
        insertStepInOpenSteps(firstStep)
        guard fromNode.nodePos.ptWho != x else {print("x"); return shortPath}
        guard toNode.nodePos.ptWho != x else {print("x"); return shortPath}
        
        repeat{
            // Get the lowest F cost step
            // Because the list is ordered, the first step is always the one with the lowest F cost
            let currentStep = openSteps[0]
            // Add the current step to the closed set
            closedSteps.append(currentStep)

            // Remove it from the open list
            openSteps.removeAtIndex(0)
            
            // If the currentStep is the desired tile coordinate, we are done!
            if currentStep.location.column == toNode.nodePos.column && currentStep.location.row == toNode.nodePos.row{
                pathFound = true
                print("Path Found")
                shortestPath = constructShortestPath(currentStep)
                shortPath.steps = shortestPath
                break
            }
//            print("Current step: \(currentStep.description)")
            // Get the adjacent tiles coord of the current step
            let adjNodes = availableAdjacentSteps(currentStep.location)
            for node in adjNodes{
                let step = ShortestPathStep(node: node)
                if (closedSteps.contains{$0 == step}){
                    continue
                }
                // Compute the cost from the current step to that step
                let moveCost = costToMoveToStep(step)
                
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
                    if let index = openSteps.indexOf(step){
                        let oldStep = openSteps[index]
                        
                        // Check to see if the G score for that step is lower if we use the current step to get there
    
                        if currentStep.gScore + moveCost < oldStep.gScore{
                            // The G score is equal to the parent G score + the cost to move from the parent to it
                            step.gScore = currentStep.gScore + moveCost;
                            
                            // Because the G Score has changed, the F score may have changed too
                            // So to keep the open list ordered we have to remove the step, and re-insert it with
                            // the insert function which is preserving the list ordered by F score
                            
                            // Now we can removing it from the list
                            openSteps.removeAtIndex(index)
                            
                            // Re-insert it with the function which is preserving the list ordered by F score
                            insertStepInOpenSteps(oldStep)
                        }
                    }
                }
//                print(step.description)
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
        
    private func insertStepInOpenSteps(step: ShortestPathStep){
        openSteps.append(step)
        openSteps.sortInPlace({
            return $0.fScore < $1.fScore
        })
    }
    
    // Compute the H score from a position to another (from the current position to the final desired position
    private func computeHScoreFromLocations(fromLoc: Location, toLoc: Location) -> Int{
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
    
    private func costToMoveToStep(toStep: ShortestPathStep) -> Int{
        
        let node = grid[toStep.location.column, toStep.location.row]
        if node?.nodePos.ptWho == o{
            return 0
        }else{
            return 1
        }
    }
    
    private func availableAdjacentSteps(location: Location) -> [Node]{
        var nodes = [Node]()
        if location.row % 2 == 0{ //the current step is a vertical line
            nodes = addNodeToArrayIfValid(column: location.column, row: location.row + 2, nodes: nodes) //top
            nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row + 1, nodes: nodes) //topleft
            nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row - 1, nodes: nodes) //bottomleft
            nodes = addNodeToArrayIfValid(column: location.column, row: location.row - 2, nodes: nodes) //bottom
            nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row + 1, nodes: nodes) //topright
            nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row - 1, nodes: nodes) //bottomright
        }else{ // current step is horizontal
            nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row + 1, nodes: nodes) //topright
            nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row + 1, nodes: nodes) //topleft
            nodes = addNodeToArrayIfValid(column: location.column - 2, row: location.row, nodes: nodes) //left
            nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row - 1, nodes: nodes) //bottomright
            nodes = addNodeToArrayIfValid(column: location.column - 1, row: location.row - 1, nodes: nodes) //bottomleft
            nodes = addNodeToArrayIfValid(column: location.column + 2, row: location.row, nodes: nodes) //right
        }
        return nodes
    }
    
    private func addNodeToArrayIfValid(column column: Int, row: Int, var nodes: [Node]) -> [Node]{
        if isValidLocation(column: column, row: row){
            if typeAtIntersection(column: column, row: row) == .Intersection && grid[column,row]?.nodePos.ptWho != x{
                nodes.append(grid[column, row]!)
            }
        }
        return nodes
    }
    
    private func isValidLocation(column column: Int, row: Int) -> Bool{
        guard (column >= 0 && column <= columns) else {return false}
        guard(row >= 0 && row <= rows) else {return false}
        return true
    }
    
    private func typeAtIntersection(column column: Int, row: Int) -> NodeType{
        let node = grid[column, row]
        return (node?.nodeType)!
    }
    
    private func constructShortestPath(var step: ShortestPathStep?) -> [ShortestPathStep]{
        var steps = [ShortestPathStep]()
        guard step != nil else {return steps}
        repeat{
            steps.insert(step!, atIndex: 0)//add every step at beginning to go from start to finish
            step = step!.parent
        }while step != nil
        
        for step in steps{//print out steps for testing
            print(step.description)
        }
        return steps
        
    }
    
    
}
