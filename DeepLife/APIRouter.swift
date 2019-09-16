//
//  Config.swift
//  DeepLife
//
//

import Foundation

class APIRoute {
    
    static let shared = APIRoute()
    
    let API_BASE_URL: String = "https://deeplife.africa/api/phone/gn_api"
    
    func toggleEventAttendance() -> String {
        
        return "\(API_BASE_URL)/toggle_event_attendance.php"
        
    }
    
    func getEventAttendanceURL() -> String {
        
        return "\(API_BASE_URL)/get_event_attendance.php"
        
    }
    
    func getEventsURL() -> String {
        
        return "\(API_BASE_URL)/get_user_events.php"
        
    }
    
    func getGroupPostsURL() -> String {
        
        return "\(API_BASE_URL)/group_posts.php"
        
    }
    
    func getGroupsURL() -> String {
        
        return "\(API_BASE_URL)/get_groups.php"
        
    }
    
    func createUploadURL() -> String {
        
        return "\(API_BASE_URL)/upload_image.php"
        
    }
    
    func createPostURL() -> String {
        
        return "\(API_BASE_URL)/create_feed_post.php"
        
    }
    
    func getCreateCommentURL() -> String {
        
        return "\(API_BASE_URL)/create_comment.php"
        
    }
    
    func getCommentsURL() -> String {
        
        return "\(API_BASE_URL)/get_comments.php"
        
    }
    
    func getFeedURL() -> String {
        
        return "\(API_BASE_URL)/get_posts.php"
        
    }
    
    func getLikeURL() -> String {
        
        return "\(API_BASE_URL)/like_post.php"
        
    }
    
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
