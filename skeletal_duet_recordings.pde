//int ANIMATION_COLOR = #64fff0;
int[] ANIMATION_COLOR = {#ffffff,#64fff0,#6400f0,#00fff0,#64f00f};
import SimpleOpenNI.*;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;

//Vectors used to calculate the center of the mass
PVector com = new PVector();
PVector com2d = new PVector();

//Up
float LeftshoulderAngle = 0;
float LeftelbowAngle = 0;
float RightshoulderAngle = 0;
float RightelbowAngle = 0;

//Legs
float RightLegAngle = 0;
float LeftLegAngle = 0;

//Timer variables
float a = 0;

class AnimationFrame{
  PVector[] joints = new PVector[16];
  PVector[] joint = new PVector[1];
  AnimationFrame(){
  }
  void addJoint(PVector jointData, int jointId){
    joints[jointId] = jointData;
  }
}

class AnimationRecording{
  ArrayList<AnimationFrame> frames = new ArrayList<AnimationFrame>() ;
  int currentFrame = -1;
  int currentPlayFrame = -1;
  

  AnimationRecording(){
    frames.add(new AnimationFrame());
  }
  
  void nextFrame(){
    if(!frames.isEmpty()){
    currentFrame++;
    frames.add(new AnimationFrame());}
  }
  
  void nextPlayFrame(){
    currentPlayFrame++;
    if(currentPlayFrame >= frames.size()){
      currentPlayFrame = 0;
    }
  }
  
  void saveJoint(PVector joint, int jointId){
    println("save joint, current frame : " + currentFrame);
    
    frames.get(currentFrame).addJoint(joint, jointId);
  }
}
//save
JSONObject json;
int windowWidth = 640;
int windowHeight = 480;
int startTime = millis();
int framesLength = 500;
int dancers = 5;
int currentDancer = 0;

AnimationRecording[] animationRecordings = new AnimationRecording[dancers];
int currentFrame = 0;
int currentPlayFrame = 0;
boolean record = false;
boolean playAnimation = false;


void setup() {
        size(1280, 960);
          frameRate(30);

        kinect = new SimpleOpenNI(this);
        kinect.enableDepth();
        //kinect.enableIR();
        kinect.enableRGB();
        kinect.enableUser();// because of the version this change
        //size(640, 480);
        fill(255, 0, 0);
        //size(kinect.depthWidth()+kinect.irWidth(), kinect.depthHeight());
        kinect.setMirror(true);
        
}

void draw() {
        
        kinect.update();
        
        scale(2);

        drawKinectImage();
        
        skeletalDetection();

        drawDancers();
        
        //drawLinesOnScreen();
      
        drawRecordIndicator();

      //fill(50,50,200);
}

void drawKinectImage(){
        //image(kinect.depthImage(), 0, 0);
        //image(kinect.irImage(),kinect.depthWidth(),0);
        //image(kinect.userImage(),0,0);
        image(kinect.rgbImage(), 0, 0); 
}
void drawRecordIndicator(){
      if(record) {
        //red recxord dot
        fill(250,0,0);
        stroke(0,0);
        ellipse(20 ,20,25,25);
      }  
}
void drawLinesOnScreen(){
      line(windowWidth/2 - 20, windowHeight/5 - 20, windowWidth/2 + 20, windowHeight/5 + 20);
      line(windowWidth/2 - 20, windowHeight/5 + 20, windowWidth/2 + 20, windowHeight/5 - 20);
      stroke(20,255,100);
      strokeWeight(6);
         
}
void skeletalDetection(){
      IntVector userList = new IntVector();
      kinect.getUsers(userList);
      if (userList.size() > 0) {
                int userId = userList.get(0);
                //If we detect one user we have to draw it
                if( kinect.isTrackingSkeleton(userId)) {
                        //DrawSkeleton
                        drawSkeleton(userId);
                        //drawUpAngles
                        ArmsAngle(userId);
                        //Draw the user Mass
                        MassUser(userId);
                        //AngleLeg
                        LegsAngle(userId);

                }
        }
}
// animationRecordings[dancer].frames.get(animationRecordings[currentDancer].currentFrame).joints.get(SimpleOpenNI.SKEL_LEFT_SHOULDER).x
void drawDancers(){
     if(currentDancer > 0 ){
        for(int dancerIndex = 0; dancerIndex < currentDancer; dancerIndex++){
          // forward frame before drawing the joints
          
          if(animationRecordings[dancerIndex] == null || animationRecordings[dancerIndex].frames.size() == 0) continue;
          println("drawing: " + animationRecordings[dancerIndex]);
          animationRecordings[dancerIndex].nextPlayFrame();
          
          stroke(ANIMATION_COLOR[dancerIndex]);
          drawLimbs(dancerIndex);
          //for(int i =1; i < 16; i++){
          //  if(animationRecordings[dancerIndex].frames.get(animationRecordings[dancerIndex].currentPlayFrame).joints.length> 1){
          //    ellipse(
          //      animationRecordings[dancerIndex].frames.get(animationRecordings[dancerIndex].currentPlayFrame).joints[i-1].x, 
          //      animationRecordings[dancerIndex].frames.get(animationRecordings[dancerIndex].currentPlayFrame).joints[i-1].y, 5,5);
          //  }
          //}
          
        }
    }
}
//Draw the skeleton
void drawSkeleton(int userId) {
        stroke(200,0,200);
        strokeWeight(2);
        float[] orientation3d = new float[16];
        PVector joint = new PVector();
        PMatrix3D joint2 = new PMatrix3D();
        float confidence = kinect.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_HEAD, joint2);
        float confidence2 = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD,joint);
        if(confidence2 < 0.3) {
                return;
        }
        //println("pose data");
        //println(joint);
        //println(joint2.get(orientation3d));
        //println(userId);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
        noStroke();
        fill(20,255,100);
       
        // new animation frame
        if(record) animationRecordings[currentDancer].nextFrame();
        
        drawJoint(userId, SimpleOpenNI.SKEL_HEAD, record);
        drawJoint(userId, SimpleOpenNI.SKEL_NECK, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, record);
        drawJoint(userId, SimpleOpenNI.SKEL_NECK, record);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, record);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, record);
        drawJoint(userId, SimpleOpenNI.SKEL_TORSO, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE, record);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT, record);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP, record);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, record);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND, record);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND, record);
        
        
        if (record) {currentFrame++;}
           
}
void drawLimbs(int dancer){
  try{
       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_HEAD].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_HEAD].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_NECK].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_NECK].y
       );
  }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_NECK].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_NECK].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_SHOULDER].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_SHOULDER].y
       );
       
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_SHOULDER].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_SHOULDER].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_ELBOW].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_ELBOW].y
       );
       
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_ELBOW].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_ELBOW].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HAND].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HAND].y
       );
       
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_NECK].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_NECK].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_SHOULDER].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_SHOULDER].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_SHOULDER].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_SHOULDER].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_ELBOW].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_ELBOW].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_ELBOW].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_ELBOW].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HAND].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HAND].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_SHOULDER].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_SHOULDER].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_SHOULDER].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_SHOULDER].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HIP].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HIP].y
       );  }catch(Exception e){
    println(e);
  };
    try{

      
       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HIP].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HIP].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_KNEE].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_KNEE].y
       );  }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_KNEE].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_KNEE].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_FOOT].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_FOOT].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_TORSO].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HIP].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HIP].y
       );  }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HIP].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HIP].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_KNEE].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_KNEE].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_KNEE].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_KNEE].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_FOOT].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_FOOT].y
       );
         }catch(Exception e){
    println(e);
  };
    try{

       line(
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HIP].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_RIGHT_HIP].y,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HIP].x,
          animationRecordings[dancer].frames.get(animationRecordings[dancer].currentPlayFrame).joints[SimpleOpenNI.SKEL_LEFT_HIP].y
       );
  }catch(Exception e){
    println(e);
  }
        //noStroke();
        fill(20,255,100); 
}
void drawJoint(int userId, int jointID, boolean record) {
        PVector joint = new PVector();
        float confidence = kinect.getJointPositionSkeleton(userId, jointID,
                                                           joint);
        if(confidence < 0.3) {
                return;
        }
        //println(joint);
        PVector convertedJoint = new PVector();
        kinect.convertRealWorldToProjective(joint, convertedJoint);
        // recording
        if(record){
          println("saving joint: " + jointID);
           animationRecordings[currentDancer].saveJoint(convertedJoint, jointID);
        }
        
        ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}
//Generate the angle
float angleOf(PVector one, PVector two, PVector axis) {
        PVector limb = PVector.sub(two, one);
        return degrees(PVector.angleBetween(limb, axis));
}

//Calibration not required

void onNewUser(SimpleOpenNI kinect, int userID) {
        println("Start skeleton tracking");
        kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
        println("onLostUser - userId: " + userId);
}

void MassUser(int userId) {
        if(kinect.getCoM(userId,com)) {
                kinect.convertRealWorldToProjective(com,com2d);
                stroke(100,100,0);
                strokeWeight(2);
                beginShape(LINES);
                vertex(com2d.x,com2d.y - 2);
                vertex(com2d.x,com2d.y + 2);
                vertex(com2d.x - 2,com2d.y);
                vertex(com2d.x + 2,com2d.y);
                endShape();
                fill(0,255,100);
                text("body " + Integer.toString(userId),com2d.x + 2,com2d.y - 4);
        }
}

public void ArmsAngle(int userId){
        // get the positions of the three joints of our right arm
        PVector rightHand = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
        PVector rightElbow = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightElbow);
        PVector rightShoulder = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightShoulder);
        // we need right hip to orient the shoulder angle
        PVector rightHip = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHip);
        // get the positions of the three joints of our left arm
        PVector leftHand = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
        PVector leftElbow = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,leftElbow);
        PVector leftShoulder = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,leftShoulder);
        // we need left hip to orient the shoulder angle
        PVector leftHip = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,leftHip);
        // reduce our joint vectors to two dimensions for right side
        PVector rightHand2D = new PVector(rightHand.x, rightHand.y);
        PVector rightElbow2D = new PVector(rightElbow.x, rightElbow.y);
        PVector rightShoulder2D = new PVector(rightShoulder.x,rightShoulder.y);
        PVector rightHip2D = new PVector(rightHip.x, rightHip.y);
        // calculate the axes against which we want to measure our angles
        PVector torsoOrientation = PVector.sub(rightShoulder2D, rightHip2D);
        PVector upperArmOrientation = PVector.sub(rightElbow2D, rightShoulder2D);
        // reduce our joint vectors to two dimensions for left side
        PVector leftHand2D = new PVector(leftHand.x, leftHand.y);
        PVector leftElbow2D = new PVector(leftElbow.x, leftElbow.y);
        PVector leftShoulder2D = new PVector(leftShoulder.x,leftShoulder.y);
        PVector leftHip2D = new PVector(leftHip.x, leftHip.y);
        // calculate the axes against which we want to measure our angles
        PVector torsoLOrientation = PVector.sub(leftShoulder2D, leftHip2D);
        PVector upperArmLOrientation = PVector.sub(leftElbow2D, leftShoulder2D);
        // calculate the angles between our joints for rightside
        RightshoulderAngle = angleOf(rightElbow2D, rightShoulder2D, torsoOrientation);
        RightelbowAngle = angleOf(rightHand2D,rightElbow2D,upperArmOrientation);
        // show the angles on the screen for debugging
        fill(20,255,100);
        scale(1);
        text("Right shoulder: " + int(RightshoulderAngle) + "\n" + " Right elbow: " + int(RightelbowAngle), 20, 20);
        // calculate the angles between our joints for leftside
        LeftshoulderAngle = angleOf(leftElbow2D, leftShoulder2D, torsoLOrientation);
        LeftelbowAngle = angleOf(leftHand2D,leftElbow2D,upperArmLOrientation);
        // show the angles on the screen for debugging
        fill(20,255,100);
        scale(1);
        text("Left shoulder: " + int(LeftshoulderAngle) + "\n" + " Left elbow: " + int(LeftelbowAngle), 20, 55);
}

void LegsAngle(int userId) {
        // get the positions of the three joints of our right leg
        PVector rightFoot = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_FOOT,rightFoot);
        PVector rightKnee = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_KNEE,rightKnee);
        PVector rightHipL = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHipL);
        // reduce our joint vectors to two dimensions for right side
        PVector rightFoot2D = new PVector(rightFoot.x, rightFoot.y);
        PVector rightKnee2D = new PVector(rightKnee.x, rightKnee.y);
        PVector rightHip2DLeg = new PVector(rightHipL.x,rightHipL.y);
        // calculate the axes against which we want to measure our angles
        PVector RightLegOrientation = PVector.sub(rightKnee2D, rightHip2DLeg);
        // calculate the angles between our joints for rightside
        RightLegAngle = angleOf(rightFoot2D,rightKnee2D,RightLegOrientation);
        fill(20,255,100);
        scale(1);
        text("Right Knee: " + int(RightLegAngle), 500, 20);
        // get the positions of the three joints of our left leg
        PVector leftFoot = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_FOOT,leftFoot);
        PVector leftKnee = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_KNEE,leftKnee);
        PVector leftHipL = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,leftHipL);
        // reduce our joint vectors to two dimensions for left side
        PVector leftFoot2D = new PVector(leftFoot.x, leftFoot.y);
        PVector leftKnee2D = new PVector(leftKnee.x, leftKnee.y);
        PVector leftHip2DLeg = new PVector(leftHipL.x,leftHipL.y);
        // calculate the axes against which we want to measure our angles
        PVector LeftLegOrientation = PVector.sub(leftKnee2D, leftHip2DLeg);
        // calculate the angles between our joints for left side
        LeftLegAngle = angleOf(leftFoot2D,leftKnee2D,LeftLegOrientation);
        // show the angles on the screen for debugging
        fill(20,255,100);
        scale(1);
        text("Leftt Knee: " + int(LeftLegAngle), 500, 55);
}
void recordMovement() {

}
void playMovement(){
}
void mouseClicked(){
  //record = !record;
  //fill(100,100,0);
  
  if (!record)
  {
    if (currentDancer < dancers){
     animationRecordings[currentDancer] = new AnimationRecording();
  
     record = true;
    }
  } 
  else 
  { 
    record = false;
    currentDancer++;  

  }
}
void keyPressed() {
  //if(key == 'm'){
  //  mirror = !mirror;
  //  kinect.enableMirror(mirror);
  //} else if (key == CODED) {
  //  if (keyCode == UP) {
  //    deg++;
  //  } else if (keyCode == DOWN) {
  //    deg--;
  //  }
  //  deg = constrain(deg, 0, 30);
  //  kinect.setTilt(deg);
  //}
}
