
/*
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://firestore.googleapis.com/v1/projects/butterfly-50d10/databases/(default)/documents/users?key=[AIzaSyB2DE6zotI7EALJf5db4g7lqp4XG7BaCxU])"
        
        let url = URL(string: urlString)
        
        guard url != nil else {
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            //check errors
            if error == nil && data != nil {
                //parse json
                let decoder = JSONDecoder()
                do {
                    
                let users = try decoder.decode(Users.self, from: data!)
                    print (users)
                }
                catch {
                print("Error in json")
                }
            }
        }
        dataTask.resume()
    }
}
//////
        fetchStructData { (profiles) in
            for profiles in profiles {
                print(profiles.fullName!)
            }
        }
    }
    func fetchStructData(completionHandler: @escaping ([Profiles]) -> Void) {
        let url = URL(string: "https://firestore.googleapis.com/v1/projects/butterfly-50d10/databases/(default)/documents/users?key=[AIzaSyB2DE6zotI7EALJf5db4g7lqp4XG7BaCxU])")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let postsData = try JSONDecoder().decode([Profiles].self, from: data)
                completionHandler(postsData)
            }
            catch {
                let error = error
                print(error.localizedDescription)
            }
        }.resume()
    }

}
*/
