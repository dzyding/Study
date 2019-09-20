//
//  camera_s.cpp
//  OpenGL_4_纹理
//
//  Created by edz on 2019/9/17.
//  Copyright © 2019 灰s. All rights reserved.
//

#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <vector>

#include <iostream>

enum Camera_Movement {
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};

//MARK: - 默认初始值
const float YAW         = -90.0f;
const float PITCH       = 0.0f;
const float SPEED       = 2.5f;
const float SENSITIVITY = 0.1f;
const float ZOOM        = 45.0f;

class Camera {
public:
    // 相机的属性
    /// 位置
    glm::vec3 _position;
    /// 方向向量(一个固定的指向，加上位置向量以后就是方向向量，确保转动的同时一直都是指向同一个地方)
    glm::vec3 _front;
    /// 上轴
    glm::vec3 _up;
    /// 右轴
    glm::vec3 _right;
    /// 定义的默认上量 (0.0f, 1.0f, 0.0f)，用于求右向量
    glm::vec3 _worldUp;
    
    // 欧拉角
    /// 偏航
    float _yaw;
    /// 附仰
    float _pitch;
    
    // 相机的参数
    /// 上下左右按键的灵敏度
    float _movementSpeed;
    /// 鼠标的灵敏度
    float _mouseSensitivity;
    /// 相机的 fov 角度
    float _zoom;
    
    Camera(glm::vec3 position = glm::vec3(0.0f),
           glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f),
           float yaw = YAW,
           float pitch = PITCH) :
            _front(glm::vec3(0.0f, 0.0f, -1.0f)),
            _movementSpeed(SPEED),
            _mouseSensitivity(SENSITIVITY),
            _zoom(ZOOM)
    {
        _position = position;
        _worldUp = up;
        _yaw = yaw;
        _pitch = pitch;
        updateCameraVectors();
    }
    
    Camera(float posX, float posY, float posZ,
           float upX, float upY, float upZ,
           float yaw, float pitch) :
            _front(glm::vec3(0.0f, 0.0f, -1.0f)),
            _movementSpeed(SPEED),
            _mouseSensitivity(SENSITIVITY),
            _zoom(ZOOM)
    {
        _position = glm::vec3(posX, posY, posZ);
        _worldUp  = glm::vec3(upX, upY, upZ);
        _yaw = yaw;
        _pitch = pitch;
        updateCameraVectors();
    }
    
    glm::mat4 getViewMatrix() {
        return glm::lookAt(_position, _position + _front, _up);
    }
    
    glm::mat4 customViewMatrix() { // 错的，不知道为什么
        // 方向向量
        glm::vec3 zaxis = glm::normalize(_position + _front);
        // 右向量
        glm::vec3 xaxis = glm::normalize(glm::cross(_worldUp, zaxis));
        // 上向量
        glm::vec3 yaxis = _up;//glm::cross(zaxis, xaxis);
        
        glm::mat4 translation = glm::mat4(1.0f);
        translation[3][0] = -_position.x;
        translation[3][1] = -_position.y;
        translation[3][2] = -_position.z;
        glm::mat4 rotation = glm::mat4(1.0f);
        rotation[0][0] = xaxis.x;
        rotation[1][0] = xaxis.y;
        rotation[2][0] = xaxis.z;
        rotation[0][1] = yaxis.x;
        rotation[1][1] = yaxis.y;
        rotation[2][1] = yaxis.z;
        rotation[0][2] = zaxis.x;
        rotation[1][2] = zaxis.y;
        rotation[2][2] = zaxis.z;
        
        return rotation * translation;
    }
    
    void processKeyboard(Camera_Movement direction, float deltaTime) {
        float velocity = _movementSpeed * deltaTime;
        if (direction == FORWARD) {
            _position += _front * velocity;
        }
        if (direction == BACKWARD) {
            _position -= _front * velocity;
        }
        if (direction == LEFT) {
            _position -= _right * velocity;
        }
        if (direction == RIGHT) {
            _position += _right * velocity;
        }
    }
    
    void processMouseMovement(float xoffset,
                              float yoffset,
                              GLboolean constrainPitch = true)
    {
        xoffset *= _mouseSensitivity;
        yoffset *= _mouseSensitivity;
        
        _yaw += xoffset;
        _pitch += yoffset;
        
        if (constrainPitch) {
            if (_pitch > 89.0f) {
                _pitch = 89.0f;
            }
            if (_pitch < -89.0f) {
                _pitch = -89.0f;
            }
        }
        updateCameraVectors();
    }
    
    void processMouseScroll(float yoffset) {
        if (_zoom >= 1.0f && _zoom <= 45.0f) {
            _zoom -= yoffset;
        }
        if (_zoom <= 1.0f) {
            _zoom = 1.0f;
        }
        if (_zoom >= 45.0f) {
            _zoom = 45.0f;
        }
    }
private:
    void updateCameraVectors() {
        glm::vec3 front = glm::vec3(0.0f);
        front.x = cos(glm::radians(_yaw)) * cos(glm::radians(_pitch));
        front.y = sin(glm::radians(_pitch));
        front.z = sin(glm::radians(_yaw)) * cos(glm::radians(_pitch));
        _front = glm::normalize(front);
        
        //规范化向量，因为向量的长度越接近0，向上或向下查看的移动速度就越慢
        _right = glm::normalize(glm::cross(_front, _worldUp));
        _up = glm::normalize(glm::cross(_right, _front));
    }
};
