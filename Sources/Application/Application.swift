import KituraCORS
import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()
    private var todoStore = [ToDo]()
    private let workerQueue = DispatchQueue(label: "worker")
    
    public init() throws {
    }

    func postInit() throws {
        let options = Options(allowedOrigin: .all)
        let cors = CORS(options: options)
        router.all("/*", middleware: cors)
        // Capabilities
        initializeMetrics(app: self)

        // Endpoints
        initializeHealthRoutes(app: self)
        
        //        Register a handler for a POST request
        router.post("/", handler: storeHandler)
//        delete
        router.delete("/", handler: deleteAllHandler)
//        get all
        router.get("/", handler: getAllHandler)
//        get one by id
        router.get("/", handler: getOneHandler)
    }
//    This expects to receive a ToDo struct from the request, sets completed to false if it is nil and adds a url value that informs the client how to retrieve this todo item in the future.
    func storeHandler(todo: ToDo, completion: (ToDo?, RequestError?) -> Void ) -> Void {
        var todo = todo
        if todo.completed == nil {
            todo.completed = false
        }
        let id = todoStore.count
        todo.url = "http://localhost:8080/\(id)"
        execute {
            todoStore.append(todo)
        }
        completion(todo, nil)
    }
    
    func deleteAllHandler(completion: (RequestError?) -> Void ) -> Void {
        execute {
            todoStore = [ToDo]()
        }
        completion(nil)
    }

    func getAllHandler(completion: ([ToDo]?, RequestError?) -> Void ) -> Void {
        completion(todoStore, nil)
    }
    
    func getOneHandler(id: Int, completion: (ToDo?, RequestError?) -> Void ) -> Void {
        completion(todoStore[id], nil)
    }
    
    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
    //    Add a helper method :make sure that access to shared resources is serialized so the app does not crash on concurrent requests.
    func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
    }
}
