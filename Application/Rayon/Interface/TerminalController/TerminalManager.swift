//
//  TerminalManager.swift
//  Rayon (macOS)
//
//  Created by Lakr Aream on 2022/3/10.
//

import Combine
import Foundation
import RayonModule

class TerminalManager: ObservableObject {
    static let shared = TerminalManager()
    private init() {}

    @Published var sessionContexts: [Context] = []

    func createSession(withMachineObject machine: RDMachine) {
        let context = Context(machine: machine)
        sessionContexts.append(context)
    }

    func createSession(withMachineID machineId: RDMachine.ID) {
        let machine = RayonStore.shared.machineGroup[machineId]
        guard machine.isNotPlaceholder() else {
            UIBridge.presentError(with: "Malformed application memory")
            return
        }
        createSession(withMachineObject: machine)
    }

    func createSession(withCommand command: SSHCommandReader) {
        let context = Context(command: command)
        sessionContexts.append(context)
    }

    func sessionExists(for machine: RDMachine.ID) -> Bool {
        for context in sessionContexts where context.machine.id == machine {
            return true
        }
        return false
    }

    func sessionAlive(forMachine machineId: RDMachine.ID) -> Bool {
        !(
            sessionContexts
                .first { $0.machine.id == machineId }?
                .closed ?? true
        )
    }

    func sessionAlive(forContext contextId: Context.ID) -> Bool {
        !(
            sessionContexts
                .first { $0.id == contextId }?
                .closed ?? true
        )
    }

    func closeSession(withMachineID machineId: RDMachine.ID) {
        let index = sessionContexts.firstIndex { $0.machine.id == machineId }
        if let index = index {
            let context = sessionContexts.remove(at: index)
            context.processShutdown()
        }
    }

    func closeSession(withContextID contextId: Context.ID) {
        let index = sessionContexts.firstIndex { $0.id == contextId }
        if let index = index {
            let context = sessionContexts.remove(at: index)
            context.processShutdown()
        }
    }

    func closeAll() {
        for context in sessionContexts {
            context.processShutdown()
        }
        sessionContexts = []
    }
}
