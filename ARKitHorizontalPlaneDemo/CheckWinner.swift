//
//  checkWinner.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/29/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation


public class CheckWinner {
    
    // TEST VARIABLES
    var cube = [[[Cell]]]()
    
    public func checkGameState() -> Bool {
        // given cell state and position check if the current player has won
        var flag = true
        
        // TEST VARIABLES
        let x = 0, y = 0, z = 0
        let currState = Cell.cellState.empty
        
        flag = true
        let checkMatrix = [
            [(1, 0, 0), (1, 0, 0), (1, 0, 0)], // x-axis
            [(0, 1, 0), (0, 1, 0), (0, 1, 0)], // y-axis
            [(0, 0, 1), (0, 0, 1), (0, 0, 1)], // z-axis
            
            [(1, 1, 0), (1, 1, 0), (1, 1, 0)], // xy plane
            [(2, 1, 0), (2, 1, 0), (2, 1, 0)],
            
            [(0, 1, 1), (0, 1, 1), (0, 1, 1)], // yz plane
            [(0, 2, 1), (0, 2, 1), (0, 2, 1)],
            
            [(1, 0, 1), (1, 0, 1), (1, 0, 1)], // xz plane
            [(2, 0, 1), (2, 0, 1), (2, 0, 1)],
            
            [(1, 1, 1), (1, 1, 1), (1, 1, 1)], // xyz
            [(1, 2, 1), (1, 2, 1), (1, 2, 1)],
            [(2, 2, 1), (2, 2, 1), (2, 2, 1)],
            [(2, 1, 1), (2, 1, 1), (2, 1, 1)]]
        
        
        for check in checkMatrix {
            flag = true
            for add in check {
                let xadd = add.0
                let yadd = add.1
                let zadd = add.2
                
                if cube[(x + xadd) % 3][(y + yadd) % 3][(z + zadd) % 3].state != currState {
                    flag = false
                }
            }
            if flag { return true }
        }
        
        return false
    }
}
