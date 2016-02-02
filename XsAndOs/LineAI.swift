//
//  LineAI.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/1/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class LineAI {
    
    private var openSteps = [ShortestPathStep]()
    private var closedSteps = [ShortestPathStep]()
    var grid : Array2D<Node>
    var pathFound = false
    
    init(grid: Array2D<Node>){
        self.grid = grid
    }
    
    func calculateShortestPath(fromNode: Node, toNode: Node){
        insertStepInOpenSteps(ShortestPathStep(node: fromNode))
        let toStep = ShortestPathStep(node: toNode)
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
                var tmpStep : ShortestPathStep? = currentStep
                print("Path Found")
                repeat{
                    print(tmpStep?.description)
                    tmpStep = tmpStep!.parent
                }while tmpStep != nil
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
                let moveCost = costToMoveFromStep(currentStep, toStep: step)
                
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
            }
        }while openSteps.count > 0
        
        if !pathFound { // No path found
            print("no path found")
        }
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
        let rs = abs(toLoc.row - fromLoc.row)
        let h = cols + rs
        print ("cols:\(cols), rows:\(rs), h:\(h)")
        return h
        // Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
        // final desired step from the current step, ignoring any obstacles that may be in the way
    }
    
    private func costToMoveFromStep(fromStep: ShortestPathStep, toStep: ShortestPathStep) -> Int{
        let intersectionLocation = Location(column: abs(fromStep.location.column - toStep.location.column), row: abs(fromStep.location.row - toStep.location.row))
        let node = grid[intersectionLocation.column, intersectionLocation.row]
        if node?.nodeType == .O{
            return 0
        }else{
            return 1
        }
    }
    
    private func availableAdjacentSteps(location: Location) -> [Node]{
        var nodes = [Node]()
        nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row + 1, nodes: nodes) //top
        nodes = addNodeToArrayIfValid(column: location.column - 2, row: location.row, nodes: nodes) //left
        nodes = addNodeToArrayIfValid(column: location.column + 1, row: location.row - 1, nodes: nodes) //bottom
        nodes = addNodeToArrayIfValid(column: location.column + 2, row: location.row, nodes: nodes) //right
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
        guard (column >= 0 && column <= grid.columns) else {return false}
        guard(row >= 0 && row <= grid.rows) else {return false}
        return true
    }
    
    private func typeAtIntersection(column column: Int, row: Int) -> NodeType{
        let node = grid[column, row]
        return (node?.nodeType)!
    }
    
    
}
