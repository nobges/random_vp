import processing.video.Movie;
import processing.video.*;

private VideoPlayer vp1;
int vc;
int vc1;

State displayPreviousState; // only used to draw
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

ArrayList< State > states2draw;
boolean doStart;

public void setup() {
  
  size(1280, 720, P3D);
  
  vp1 = new VideoPlayer( this, "Time of Flight-HD.mp4"); //VIDEO
  
  //Create video cues (seconds)
  vp1.addCue( 0, 1 );
  vp1.addCue( 14, 15 );
  vp1.addCue( 42, 43 );
  vp1.addCue( 54, 55 );
  vp1.addCue( 69, 70 );
  vp1.addCue( 108, 109 );
  
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
  
  // registration of states to draw
  {
    states2draw = new ArrayList< State >();
    
    stateStop.position.set( 50, 300 );
    states2draw.add( stateStop );
    
    stateA.position.set( 150, 300 );
    states2draw.add( stateA );
    
    stateB1.position.set( 250, 200 );
    states2draw.add( stateB1 );
    
    stateB2.position.set( 250, 400 );
    states2draw.add( stateB2 );
    
    stateC1.position.set( 250, 100 );
    states2draw.add( stateC1 );
    
    stateC2.position.set( 250, 500 );
    states2draw.add( stateC2 );
    
  }
  
  displayPreviousState = null;
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
    displayPreviousState = previousState;
    // println( "on vient de changer de state!" );
    if ( currentState == stateStop ) {
      vp1.pause();
      println( "c'est la fin!" );
    } else if ( previousState == stateStop ) {
      println( "c'est le début!" );
    }
  }
  previousState = currentState;
  
  // drawing states
  // first: links
  for ( State s : states2draw ) {
    for ( Link l : s.links ) {
      if ( 
        ( displayPreviousState == l.origin && currentState == l.target ) || 
        ( displayPreviousState == l.target && currentState == l.origin )
        ) {
        strokeWeight( 3 );
        stroke( 255, 0, 0 );
      } else {
        strokeWeight( 1 );
        stroke( 255 );
      }
      line( l.origin.position.x, l.origin.position.y, l.target.position.x, l.target.position.y );
    }
  }
  // second: draw states
  strokeWeight( 1 );
  pushMatrix();
  translate( 0, 0, 1 );
  for ( State s : states2draw ) {
    stroke( 255 );
    if ( s == currentState ) {
      fill( 255,0,0 );
    } else {
      fill( 0, 80 );
    }
    ellipse( s.position.x, s.position.y, 70, 70 );
    fill( 255 );
    text( s.name, s.position.x -25, s.position.y + 4 );
    
  }
  popMatrix();
  
  fill( 255 );
  text( "" + vp1.isRunning() + "\n" + vp1.isPlaying(), 10, 25 );
  
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