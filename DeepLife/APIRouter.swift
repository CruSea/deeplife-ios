//
//  Config.swift
//  DeepLife
//
//

import Foundation

class APIRoute {
    
    static let shared = APIRoute()
    
    let API_BASE_URL: String = "https://deeplife.africa/api/phone/gn_api"
    
    func getTaskListURL() -> String {
        
        return "\(API_BASE_URL)/get_task_list.php"
        
    }
    
    func getUserDataURL() -> String {
        
        return "\(API_BASE_URL)/get_user_data.php"
        
    }
    
    func getTaskDetailsURL() -> String {
        
        return "\(API_BASE_URL)/get_task_details.php"
        
    }
    
    func updateTaskStatusURL() -> String {
        
        return "\(API_BASE_URL)/update_task_status.php"
        
    }
    
    func addTaskURL() -> String {
        
       return "\(API_BASE_URL)/add_task.php"
        
    }
    
    func getCountriesListURL() -> String {
        
        return "\(API_BASE_URL)/get_countries.php"
        
    }
    
    func getAddExposureURL() -> String {
        
        return "\(API_BASE_URL)/add_exposure.php"
        
    }
    
    func getExposureURL() -> String {
        
        return "\(API_BASE_URL)/get_exposure.php"
        
    }
    
    func logoutURL() -> String {
        
        return "\(API_BASE_URL)/logout.php"
        
    }
    
    func loginURL() -> String {
        
        return "\(API_BASE_URL)/login.php"
        
    }
    
    func getDiscipleCountURL() -> String {
        
        return "\(API_BASE_URL)/get_disciple_count.php"
        
    }
    
    func getDiscipleListURL() -> String {
        
        return "\(API_BASE_URL)/get_disciples_list.php"
        
    }
    
    func updateDeepStageURL() -> String {
        
        return "\(API_BASE_URL)/update_disciple_deep_stage.php"
        
    }
    
    func addDiscipleURL() -> String {
        
        return "\(API_BASE_URL)/add_disciple.php"
        
    }
    
    func getTreeURL() -> String {
        
        return "\(API_BASE_URL)/get_tree.php"
        
    }
    
    func getCreateAccountURL() -> String {
        
        return "\(API_BASE_URL)/create_account.php"
        
    }
    
}