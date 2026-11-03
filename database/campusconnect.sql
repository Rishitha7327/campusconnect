
-- =========================================================
-- CAMPUSCONNECT : COMPLETE DATABASE
-- MySQL 8.0+
-- =========================================================

CREATE DATABASE IF NOT EXISTS campusconnect_complete;
USE campusconnect_complete;


-- =========================================================
-- 1. USERS
-- =========================================================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('STUDENT','FACULTY','ADMIN') NOT NULL DEFAULT 'STUDENT',
    profile_picture VARCHAR(500),
    account_status ENUM('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- =========================================================
-- 2. STUDENT DETAILS
-- =========================================================

CREATE TABLE student_details (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    roll_number VARCHAR(30) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    branch VARCHAR(100) NOT NULL,
    year_of_study INT NOT NULL,
    section VARCHAR(20),
    phone VARCHAR(15),
    bio TEXT,
    skills TEXT,
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 3. FACULTY DETAILS
-- =========================================================

CREATE TABLE faculty_details (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    employee_id VARCHAR(30) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    designation VARCHAR(100),
    phone VARCHAR(15),
    bio TEXT,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 4. PASSWORD RESET TOKENS
-- =========================================================

CREATE TABLE password_reset_tokens (
    token_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    used BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 5. POSTS
-- =========================================================

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200),
    content TEXT NOT NULL,
    post_type ENUM('GENERAL','ANNOUNCEMENT','EVENT','PROJECT') DEFAULT 'GENERAL',
    visibility ENUM('PUBLIC','CONNECTIONS','PRIVATE') DEFAULT 'PUBLIC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 6. POST MEDIA
-- =========================================================

CREATE TABLE post_media (
    media_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    media_url VARCHAR(500) NOT NULL,
    media_type ENUM('IMAGE','VIDEO','DOCUMENT') NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(post_id)
);


-- =========================================================
-- 7. POST LIKES
-- =========================================================

CREATE TABLE post_likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (post_id, user_id),

    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 8. COMMENTS
-- =========================================================

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id INT,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id)
);


-- =========================================================
-- 9. COMMENT LIKES
-- =========================================================

CREATE TABLE comment_likes (
    comment_like_id INT PRIMARY KEY AUTO_INCREMENT,
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (comment_id, user_id),

    FOREIGN KEY (comment_id) REFERENCES comments(comment_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 10. POST SHARES
-- =========================================================

CREATE TABLE post_shares (
    share_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    caption VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 11. FRIENDSHIPS
-- =========================================================

CREATE TABLE friendships (
    friendship_id INT PRIMARY KEY AUTO_INCREMENT,
    requester_id INT NOT NULL,
    receiver_id INT NOT NULL,
    status ENUM('PENDING','ACCEPTED','REJECTED','CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE (requester_id, receiver_id),
    CHECK (requester_id <> receiver_id),

    FOREIGN KEY (requester_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES users(user_id)
);


-- =========================================================
-- 12. CONVERSATIONS
-- =========================================================

CREATE TABLE conversations (
    conversation_id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_type ENUM('DIRECT','GROUP') NOT NULL DEFAULT 'DIRECT',
    conversation_name VARCHAR(150),
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES users(user_id)
);


-- =========================================================
-- 13. CONVERSATION PARTICIPANTS
-- =========================================================

CREATE TABLE conversation_participants (
    participant_id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_at DATETIME,

    UNIQUE (conversation_id, user_id),

    FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 14. MESSAGES
-- =========================================================

CREATE TABLE messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    message_text TEXT,
    message_type ENUM('TEXT','IMAGE','FILE') DEFAULT 'TEXT',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_at DATETIME,
    is_deleted BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id),
    FOREIGN KEY (sender_id) REFERENCES users(user_id)
);


-- =========================================================
-- 15. MESSAGE ATTACHMENTS
-- =========================================================

CREATE TABLE message_attachments (
    attachment_id INT PRIMARY KEY AUTO_INCREMENT,
    message_id INT NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255),
    file_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (message_id) REFERENCES messages(message_id)
);


-- =========================================================
-- 16. EVENTS
-- =========================================================

CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,

    event_type ENUM('ONLINE','OFFLINE','HYBRID') NOT NULL,

    event_date DATETIME NOT NULL,
    end_date DATETIME,
    location VARCHAR(200),
    meeting_link VARCHAR(500),

    organizer_id INT NOT NULL,
    max_participants INT,
    status ENUM('UPCOMING','ONGOING','COMPLETED','CANCELLED') DEFAULT 'UPCOMING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (organizer_id) REFERENCES users(user_id)
);


-- =========================================================
-- 17. EVENT REGISTRATIONS
-- =========================================================

CREATE TABLE event_registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    status ENUM('REGISTERED','CANCELLED','ATTENDED') DEFAULT 'REGISTERED',

    UNIQUE (event_id, user_id),

    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 18. CLUBS
-- =========================================================

CREATE TABLE clubs (
    club_id INT PRIMARY KEY AUTO_INCREMENT,
    club_name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(100),
    logo_url VARCHAR(500),
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES users(user_id)
);


-- =========================================================
-- 19. CLUB MEMBERS
-- =========================================================

CREATE TABLE club_members (
    club_member_id INT PRIMARY KEY AUTO_INCREMENT,
    club_id INT NOT NULL,
    user_id INT NOT NULL,

    role ENUM('MEMBER','PRESIDENT','SECRETARY','ADMIN') DEFAULT 'MEMBER',

    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (club_id, user_id),

    FOREIGN KEY (club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 20. CLUB POSTS
-- =========================================================

CREATE TABLE club_posts (
    club_post_id INT PRIMARY KEY AUTO_INCREMENT,
    club_id INT NOT NULL,
    user_id INT NOT NULL,
    title VARCHAR(200),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 21. NOTIFICATIONS
-- =========================================================

CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message VARCHAR(500) NOT NULL,

    notification_type ENUM(
        'POST','COMMENT','LIKE','EVENT',
        'FRIEND_REQUEST','MESSAGE','CLUB','GENERAL'
    ) DEFAULT 'GENERAL',

    reference_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 22. RESOURCE CATEGORIES
-- =========================================================

CREATE TABLE resource_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);


-- =========================================================
-- 23. ACADEMIC RESOURCES
-- =========================================================

CREATE TABLE resources (
    resource_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    uploaded_by INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    subject VARCHAR(100),
    semester INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES resource_categories(category_id),
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id)
);


-- =========================================================
-- 24. LOST AND FOUND ITEMS
-- =========================================================

CREATE TABLE lost_found_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    description TEXT,
    item_type ENUM('LOST','FOUND') NOT NULL,
    location VARCHAR(200),
    item_image VARCHAR(500),
    item_date DATETIME,
    status ENUM('OPEN','CLAIMED','CLOSED') DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 25. ITEM CLAIMS
-- =========================================================

CREATE TABLE item_claims (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    claimant_id INT NOT NULL,
    claim_message TEXT,
    status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (item_id) REFERENCES lost_found_items(item_id),
    FOREIGN KEY (claimant_id) REFERENCES users(user_id)
);


-- =========================================================
-- 26. INTERNSHIP AND PLACEMENT POSTS
-- =========================================================

CREATE TABLE internship_posts (
    internship_id INT PRIMARY KEY AUTO_INCREMENT,
    posted_by INT NOT NULL,
    company_name VARCHAR(150) NOT NULL,
    job_title VARCHAR(200) NOT NULL,
    description TEXT,
    eligibility TEXT,
    location VARCHAR(200),
    job_type ENUM('INTERNSHIP','FULL_TIME','PART_TIME') NOT NULL,
    application_url VARCHAR(500),
    stipend VARCHAR(100),
    deadline DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (posted_by) REFERENCES users(user_id)
);


-- =========================================================
-- 27. INTERNSHIP APPLICATIONS
-- =========================================================

CREATE TABLE internship_applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    internship_id INT NOT NULL,
    user_id INT NOT NULL,
    resume_url VARCHAR(500),
    cover_letter TEXT,

    status ENUM(
        'APPLIED','SHORTLISTED','REJECTED','SELECTED'
    ) DEFAULT 'APPLIED',

    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (internship_id, user_id),

    FOREIGN KEY (internship_id) REFERENCES internship_posts(internship_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 28. STUDENT PROJECTS
-- =========================================================

CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    created_by INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    tech_stack VARCHAR(500),
    github_url VARCHAR(500),
    demo_url VARCHAR(500),
    project_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES users(user_id)
);


-- =========================================================
-- 29. PROJECT MEMBERS
-- =========================================================

CREATE TABLE project_members (
    project_member_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(100),

    UNIQUE (project_id, user_id),

    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- =========================================================
-- 30. CAMPUS MARKETPLACE
-- =========================================================

CREATE TABLE marketplace_listings (
    listing_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    item_condition ENUM('NEW','LIKE_NEW','GOOD','FAIR') DEFAULT 'GOOD',
    image_url VARCHAR(500),
    location VARCHAR(200),

    status ENUM('AVAILABLE','SOLD','REMOVED') DEFAULT 'AVAILABLE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (seller_id) REFERENCES users(user_id)
);


-- =========================================================
-- 31. REPORTS
-- =========================================================

CREATE TABLE reports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    reporter_id INT NOT NULL,
    reported_user_id INT,
    post_id INT,

    reason VARCHAR(200) NOT NULL,
    description TEXT,

    status ENUM('PENDING','REVIEWED','RESOLVED','DISMISSED')
        DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (reporter_id) REFERENCES users(user_id),
    FOREIGN KEY (reported_user_id) REFERENCES users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
);


-- =========================================================
-- 32. ADMIN ACTIONS
-- =========================================================

CREATE TABLE admin_actions (
    action_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    target_user_id INT,
    action_type VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (admin_id) REFERENCES users(user_id),
    FOREIGN KEY (target_user_id) REFERENCES users(user_id)
);


-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_events_event_date ON events(event_date);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_resources_category_id ON resources(category_id);
CREATE INDEX idx_internship_deadline ON internship_posts(deadline);
CREATE INDEX idx_marketplace_status ON marketplace_listings(status);


-- =========================================================
-- VERIFY DATABASE
-- =========================================================

SHOW TABLES;
