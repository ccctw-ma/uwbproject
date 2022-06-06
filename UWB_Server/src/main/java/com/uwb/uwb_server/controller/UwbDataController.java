package com.uwb.uwb_server.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author msc
 * @version 1.0
 * @date 2022/5/31 15:40
 */
@RestController
@RequestMapping("/uwb")
public class UwbDataController {

    @GetMapping("kalman")
    public String kalmanFilter() {
        return "Hello kalman Filter";
    }
}
