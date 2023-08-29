import time
import numpy as np
import requests
import pygame

import threading

# Initialize Pygame
pygame.init()

# Constants
gravity = 9.81  # m/s^2, acceleration due to gravity
initial_height = 400  # pixels, initial height of the drone
window_width = 800
window_height = 600
drone_size = 20

# Colors
black = (0, 0, 0)
white = (255, 255, 255)

# Create the display
screen = pygame.display.set_mode((window_width, window_height))
pygame.display.set_caption("Drone Simulation")

class Object:
    def __init__(self):
        self.weight = 1
        self.position = np.array([0,0,0], dtype=float)
        self.speed = np.array([0,0,0], dtype=float)
        self.acceleration = np.array([0,0,0], dtype=float)


def send_recv_data(drone):
    data = {
        "position_x": str(drone.position[0]),
        "position_y": str(drone.position[1]),
        "position_z": str(drone.position[2])
    }
    response = requests.get("http://localhost:8080", params=data, json=data)
    if response.status_code == 200:
        return response.json()["force"]
    return None

class Simulation:
    def __init__(self):
        self.drone = Object()
        self.objects = [self.drone]
        self.wind_speed = np.array([1, 0, 0])
        self.gravity_acceleration = 9.81
        self.received_force = None
        self.quit = False

    def update_positions(self, time_step):
        for obj in self.objects:
            obj.position += obj.speed * time_step

    def update_speeds(self, time_step):
        for obj in self.objects:
            obj.speed += obj.acceleration * time_step
    
    def calculate_accelerations(self):
        # start with gravity
        for obj in self.objects:
            if obj.position[1] > 0:
                obj.acceleration = np.array([0, -self.gravity_acceleration, 0], dtype=float)
            else:
                obj.acceleration = np.array([0, 0, 0], dtype=float)
        # add wind
        for obj in self.objects:
            if obj.position[1] > 0:
                wind_force = 0.05 * (self.wind_speed - obj.speed) * abs(self.wind_speed - obj.speed) 
                obj.acceleration +=  np.array(wind_force / obj.weight, dtype=float)
        # drone force
        if self.received_force != None:
            self.drone.acceleration =  self.drone.acceleration + np.array(self.received_force, dtype=float)

    def floor_collision(self):
        for obj in self.objects:
            if obj.position[1] < 0:
                obj.position[1] = 0

    def run(self):
        t1 = time.time()
        t2 = time.time()
        print_time = t2
        while not self.quit:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.quit = True
                    pygame.quit()
                    quit()
            time_step = (t2 - t1)
            self.calculate_accelerations()
            self.update_positions(time_step)
            self.floor_collision()
            self.update_speeds(time_step)
            t1 = t2
            time.sleep(0.05)
            t2 = time.time()
            if t2 - print_time > 1:
                print("___________________________________________________")
                print("time_step:", time_step)
                print("position:", self.drone.position)
                print("speed:", self.drone.speed)
                print("acceleration:", self.drone.acceleration)
                print_time = t2
            
            screen.fill(white)  # Clear the screen
            pygame.draw.circle(screen, black, (window_width // 4 + int(30 * self.drone.position[0]), int(window_height - 30 * self.drone.position[1])), drone_size)
            pygame.display.update()

    def run_communication(self):
        while not self.quit:
            time.sleep(0.1)
            self.received_force = send_recv_data(self.drone)


sim = Simulation()
t1 = threading.Thread(target=sim.run)
t2 = threading.Thread(target=sim.run_communication)

t1.start()
t2.start()
t1.join()
t2.join()