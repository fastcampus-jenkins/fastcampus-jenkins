package com.fastcampus.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class DemoController {
    @GetMapping("/")
    fun home(): Map<String, String> {
        var a = 4
        a = a+ 3
        
        return mapOf(
            
            
            
            "version" to "1.0",
            "hello" to "world"
        )
    }
}
