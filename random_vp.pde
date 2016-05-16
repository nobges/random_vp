import processing.video.Movie;
import processing.video.*;

private VideoPlayer vp1;
int vc;
int vc1;

State previousState;
State currentState;
State stateStop;

State stateA;

// etape 2
State stateB1;
State stateB2;
State stateC1;
State stateC2;
State stateD1;
State stateD2;
State stateE1;
State stateE2;

// etape 3
State stateF1;
State stateF2;
State stateF3;
State stateG1;
State stateG2;
State stateG3;
State stateH1;
State stateH2;
State stateH3;
State stateI1;
State stateI2;
State stateI3;

boolean doStart;

public void setup() {
  
  size(1280, 720, P3D);
  
  vp1 = new VideoPlayer( this, "BAC3_CASO_preprod.mov"); //VIDEO
  
  //Create video cues (seconds)
  vp1.addCue( 0, 1 );
  vp1.addCue( 0, 5 );
  vp1.addCue( 7, 12 );
  vp1.addCue( 15, 20 );
  vp1.addCue( 23, 28 );
  vp1.addCue( 31, 36 );
  
  
  //STATES
  stateStop = new State( "stateStop", vp1, -1 );
  
  stateA = new State( "stateA", vp1, 1 );
  stateStop.addlink( stateA, 1 );
  
  stateB1 = new State( "stateB1", vp1, 2 );
  stateB2 = new State( "stateB2", vp1, 3 );
  stateA.addlink( stateB1, 1 );
  stateA.addlink( stateB2, 1 );
  
  stateC1 = new State( "stateC1", vp1, 4 );
  stateC2 = new State( "stateC2", vp1, 5 );
  stateB1.addlink( stateC1, 1 );
  stateB2.addlink( stateC2, 1 );
  
  stateC1.addlink( stateStop, 1 );
  stateC2.addlink( stateStop, 1 );
  
  currentState = stateStop;
  previousState = currentState;
  doStart = true;
  
  vp1.volume( 0 );
  
  frameRate( 60 );
}

public void draw() {
 
  background( 0, 0, 0 );
  
  if ( doStart && currentState == stateStop) {
    println("start");
    doStart = false;
    currentState = stateA;
    currentState.activateCue();
    vp1.start();
  }
  vp1.draw();
  
  //println( frameCount + " : " + previousState.name + " > " + currentState.name );
  if ( previousState != currentState ) {
    println( "on vient de changer de state!" );
    if ( currentState == stateStop ) {
      vp1.stop();
      println( "c'est la fin!" );
    } else if ( previousState == stateStop ) {
      println( "c'est le début!" );
    }
  }
  previousState = currentState;
}

public void exit() {
  //vp1.suspend();
  super.exit();
}

public void mousePressed() {
  //vp1.nextCue();
  doStart = true;
}

public void movieEvent(Movie m) { 
  m.read();
}