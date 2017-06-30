#########################################################
#
#
#  PONGER.PY   - A pong game clone
#
#  
#
#   31st August 2008
#
#   rsbrooks@gmail.com
#
#
#
#
#########################################################





######### IMPORTS ###################################################
import random, math, pygame
from pygame.locals import *
import matlab.engine
import Queue
import thread

eng = matlab.engine.start_matlab()
eng.cd(r'D:\000Minor\ZoekenSturenBewegen\eyetracking_code')

cam = eng.initialize_cam()

print 'give left calibration value'
calibrationLeft = float(raw_input()) 
print 'give right calibration value'
calibrationRight = float(raw_input())

q = Queue.LifoQueue()

def matlabAPI():
    while True: 
        matlabOutput = eng.gaze_tracking('y', 0, cam, calibrationLeft, calibrationRight)
        q.put(matlabOutput)

def main():
    run = 1
    while run == 1:
        ###### CONSTANTS
        WINSIZE = [1920,1080]
        WHITE = [255,255,255]
        BLACK = [0,0,0]
        RED = [255,0,0]
        GREEN = [0,255,0]
        BLUE = [0,0,255]
        BLOCKSIZE = [20,20]
        MAXX = 1060
        MINX = 20
        MAXY = 1060
        MINY = 0
        BLOCKSTEP = 20
        TRUE = 1
        FALSE = 0
        PADDLELEFTYVAL = 25 
        PADDLERIGHTYVAL = 775
        LEFT = 1
        RIGHT = 0
        PADDLESTEP = 4 ## was 3
        
        ###### VARIABLES

        paddleleftxy = [5,200]
        paddlerightxy = [1055,200]
        scoreleft = 0
        scoreright = 0
        gameover = TRUE
        ballxy = [200,200]
        
        ballspeed = 2
        balldy = 1
        balldx = 1

        ballservice = TRUE
        service = LEFT
        scoreleft = 0
        scoreright = 0


        ballcludge = 0 # added for problems with right paddle
        
        pygame.init()
        clock = pygame.time.Clock()
        screen = pygame.display.set_mode((0,0), pygame.FULLSCREEN, 0)
        pygame.display.set_caption('PONGER')
        screen.fill(BLACK)
        paddle = pygame.image.load('paddle.bmp').convert()
        paddleerase = pygame.image.load('paddleerase.bmp').convert()
        ball = pygame.image.load('ball.bmp').convert()
        ballerase = pygame.image.load('ballerase.bmp').convert()
        textleft = [1,1,2,2]
        textright = [3,3,4,4]

        ############ title screen
        
        while gameover == TRUE:

            font = pygame.font.SysFont("arial", 32)
            text_surface = font.render("PONGER", True, BLUE)
            screen.blit(text_surface, (80,40))
            text_surface = font.render("Left paddle A and Z to move", True, BLUE)
            screen.blit(text_surface, (80,120))
            text_surface = font.render("Right paddle UP and DOWN to move", True, BLUE)
            screen.blit(text_surface, (80,160))
            text_surface = font.render("S or RETURN to serve the ball", True, BLUE)
            screen.blit(text_surface, (80,200))
            text_surface = font.render("P to pause, R to resume, Q to quit", True, BLUE)
            screen.blit(text_surface, (80,240))
            text_surface = font.render("Press N to start a new game", True, BLUE)
            screen.blit(text_surface, (80,280))
            pygame.display.update()

            for event in pygame.event.get():
                if event.type == QUIT:
                    exit()
                    
            pressed_keys = pygame.key.get_pressed()
            
            if pressed_keys[K_n]:
                gameover = FALSE
                screen.fill(BLACK)
            elif pressed_keys[K_q]:
                run = 0
                exit()

            clock.tick(20)
            

        ###### main game loop
            
        while not gameover:
            
            
            ##### clear screen on paddles and ball and print scores
            
            screen.blit(paddleerase,paddleleftxy)
            screen.blit(paddleerase,paddlerightxy)
            screen.blit(ballerase,ballxy)

            font = pygame.font.SysFont("arial", 64)
            text_surface1 = font.render(str(scoreleft), True, BLUE)
            textleft = screen.blit(text_surface1, (40,40))
            text_surface1 = font.render(str(scoreright), True, BLUE)
            textright = screen.blit(text_surface1, (1820,40))


            ##### parse input events and move paddles
            
            for event in pygame.event.get():
                if event.type == QUIT:
                    exit()
                    
            pressed_keys = pygame.key.get_pressed()
            #matlabInput = eng.gaze_tracking('y', 0, cam, calibrationLeft, calibrationRight)

            if q.qsize() > 0:
                matlabInput = q.get_nowait()

                if matlabInput == 'Up':
                    if paddleleftxy[1] > MINY:
                        paddleleftxy[1] = paddleleftxy[1] - PADDLESTEP

                elif matlabInput == 'Down':
                    if paddleleftxy[1] < MAXY - 80:
                        paddleleftxy[1] = paddleleftxy[1] + PADDLESTEP

                    
            if pressed_keys[K_UP]:
                if paddlerightxy[1] > MINY:
                    paddlerightxy[1] = paddlerightxy[1] - PADDLESTEP

            elif pressed_keys[K_DOWN]:
                if paddlerightxy[1] < MAXY - 80:
                    paddlerightxy[1] = paddlerightxy[1] + PADDLESTEP

            ### serve the ball if we are serving !
            if (pressed_keys[K_s] or pressed_keys[K_RETURN]) and ballservice == TRUE:
                ballservice = FALSE
                if service == LEFT:
                    ## introduce random ball direction on serve
                    balldx = random.randrange(2,3)
                    balldy = random.randrange(-3,3)
                    service = RIGHT
                else:
                    ## introduce random ball direction on serve
                    balldx = random.randrange(2,3)
                    balldy = random.randrange(-3,3)
                    service == LEFT
                
            if pressed_keys[K_q]:
                run = 0
                exit()

            if pressed_keys[K_p]:
                gamepaused = TRUE
                font = pygame.font.SysFont("arial", 64)
                paused_surface = font.render("PAUSED", True, BLUE)
                paused_rect = screen.blit(paused_surface, (900,400))
                pygame.display.update()

                while gamepaused == TRUE:

                    for event in pygame.event.get():
                        if event.type == QUIT:
                            exit()
                    
                    pressed_keys = pygame.key.get_pressed()

                    if pressed_keys[K_r]:
                        gamepaused = FALSE
                    clock.tick(20)

                pygame.draw.rect(screen,BLACK,paused_rect)
                


            #### if not serving just move the ball
            if ballservice is not TRUE:
                ## have we hit the left paddle
                if ballxy[0] <(paddleleftxy[0] + 20) and ballxy[1] > (paddleleftxy[1] - 18) and ballxy[1] < (paddleleftxy[1] + 98):
                    balldx = -balldx
                    if q.qsize() > 0:
                        matlabInput = q.get_nowait()
                        if matlabInput == 'Up' or matlabInput == 'Down':
                            balldy = random.randrange(2,4)
                        else:
                            balldy = random.randrange(0,3)
                        
                ## have we hit the right paddle
                elif ballxy[0] > (paddlerightxy[0] - 20) and ballxy[1] > (paddlerightxy[1] - 18) and ballxy[1] <= (paddlerightxy[1] + 98):
                    ### had to include ballcludge counter here to make sure ball did not bounce round paddle - Never seen
                    ### any behaviour like this on the left paddle so not added there
                    if ballcludge == 0:
                        balldx = -balldx
                        if pressed_keys[K_UP] or pressed_keys[K_DOWN]:
                            balldy = random.randrange(2,4)
                        else:
                            balldy = random.randrange(0,3)
                        ballcludge = 1
                    else:
                        ballcludge = ballcludge + 1
                        if ballcludge == 4:
                            ballcludge = 0
                            
                ## have we hit the top of screen
                elif ballxy[1] <= MINY:
                    #1#ballanglerad = -ballanglerad
                    balldy = -balldy
                ## have we hit the bottom of screen
                elif ballxy[1] >= MAXY:
                    #1#ballanglerad = -ballanglerad
                    balldy = -balldy
                ## have we passed the left paddle
                elif ballxy[0] <= MINX:
                    ballservice = TRUE
                    service = RIGHT
                    scoreright = scoreright + 1
                    ## clear the score right text
                    pygame.draw.rect(screen,BLACK,textright)
                ## have we passed the right paddle
                elif ballxy[0] >= MAXX:
                    ballservice = TRUE
                    service = LEFT
                    scoreleft = scoreleft + 1
                    ## clear the score left text 
                    pygame.draw.rect(screen,BLACK,textleft)
                    
                ### lets actually move the ball now we have the deltas
                ballxy[0] = ballxy[0] + (ballspeed * balldx)
                ballxy[1] = ballxy[1] + (ballspeed * balldy)

            ####  if we are serving set up the ball by the paddle
            else:
                if service == LEFT:
                    ballxy[0] = paddleleftxy[0] + 25
                    ballxy[1] = paddleleftxy[1] + 40
                elif service == RIGHT:
                    ballxy[0] = paddlerightxy[0] - 25
                    ballxy[1] = paddlerightxy[1] + 40
            
            
            ###### RENDER SCREEN
    
            screen.blit(paddle,paddleleftxy)
            screen.blit(paddle,paddlerightxy)
            screen.blit(ball,ballxy)
            pygame.display.update()

          
            clock.tick(100)
        

if __name__ == '__main__':
    #main()
    try:
        thread.start_new_thread( matlabAPI, () )
        thread.start_new_thread( main, () )

    except:
        print "Error: unable to start thread"

    while 1:
        pass