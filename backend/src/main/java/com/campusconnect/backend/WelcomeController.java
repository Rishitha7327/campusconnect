package com.campusconnect.backend;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
@RestController 
public class WelcomeController {
    @GetMapping("/Welcome")
    public String welcome() {
        return "Welcome to CampusConnect!";
    }
}
