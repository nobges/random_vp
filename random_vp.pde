import processing.video.Movie;
import processing.video.*;

private VideoPlayer vp1;
int vc;
int vc1;

State displayPreviousState; // only used to draw
State previousState;
State currentState;
State stateStop;

ArrayList< State > states2draw;
boolean doStart;
boolean dispayMarkov;

public void setup() {
  
  size( 1280, 720, P3D );
  
  //vp1 = new VideoPlayer( this, "Time of Flight-HD.mp4"); //VIDEO
  vp1 = new VideoPlayer( this, "glitch-dance.mkv");
  
  states2draw = new ArrayList< State >();
  
  int stnum = 60;
  int stnum_half = stnum / 2;
  float t_offset1 = 72;
  float t_offset2 = 46;
  
  int j;
  for ( int i = 0; i < stnum; ++i ) {
    if ( i < stnum_half ) {
      j = i;
      vp1.addCue( t_offset1 + j * 0.011, t_offset1 + 0.05 + j * 0.011 );
      State s = new State( "s" + i, vp1, i );
      //s.addlink( s, 2 );
      float a = PI * 4 / stnum * j;
      s.position.set( width * 0.5 + cos( a ) * 325, height * 0.5 + sin( a ) * 325 );
      states2draw.add( s );
    } else {
      j = i - stnum_half;
      vp1.addCue( t_offset2 + j * 0.12, t_offset2 + 0.3 + j * 0.12 );
      State s = new State( "s" + i, vp1, i );
      //s.addlink( s, 2 );
      float a = PI * 4 / stnum * j + PI * 2 / stnum;
      s.position.set( width * 0.5 + cos( a ) * 280, height * 0.5 + sin( a ) * 280 );
      states2draw.add( s );
    }
  }
  // building network
  for ( int i = 0; i < stnum; ++i ) {
    if ( i < stnum_half ) {
      int next = ( i + 1 ) % stnum_half;
      int previous = ( i + stnum_half - 1 ) % stnum_half;
      if ( random( 0, 1 ) > 0.7 ) {
        int jumper = ( i + (int) random( 10, 15 ) ) % stnum_half;
        states2draw.get( i ).addlink( states2draw.get( jumper ), 1 );
      }
      if ( random( 0, 1 ) > 0.8 ) {
        int jumper = stnum_half + ( i + (int) random( 10, 15 ) ) % stnum_half;
        states2draw.get( i ).addlink( states2draw.get( jumper ), 1 );
      }
      states2draw.get( i ).addlink( states2draw.get( next ), 1 );
      states2draw.get( i ).addlink( states2draw.get( previous ), 1 );
      
    } else {
      
      /*
      int next = stnum_half + ( i + 1 ) % stnum_half;
      int previous = stnum_half + ( i + stnum_half - 1 ) % stnum_half;
      states2draw.get( i ).addlink( states2draw.get( next ), 1 );
      states2draw.get( i ).addlink( states2draw.get( previous ), 1 );
      */
      
      for ( int o = -stnum_half / 2; o < stnum_half / 2; ++o ) {
        int opposite = stnum_half + ( o + stnum_half ) % stnum_half;
        if ( i == opposite ) continue;
        states2draw.get( i ).addlink( states2draw.get( opposite ), 1 );
      }
    
      if ( random( 0, 1 ) > 0.6 ) {
        int jumper = i - stnum_half;
        states2draw.get( i ).addlink( states2draw.get( jumper ), 10 );
      }
    
  }
    
  }
  
  displayPreviousState = null;
  currentState = stateStop;
  previousState = currentState;
  doStart = true;
  dispayMarkov = false;
  
  vp1.volume( 0 );
  
  frameRate( 60 );
 
  currentState = states2draw.get( 0 );
  currentState.activateCue();
  vp1.start();
  
}

public void draw() {
 
  background( 0, 0, 0 );
  
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
  
  if ( !dispayMarkov ) {
    return;
  }
  
  // drawing states
  // first: links
  noFill();
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
        stroke( 255, 50 );
      }
      if ( l.origin != l.target ) {
        line( l.origin.position.x, l.origin.position.y, l.target.position.x, l.target.position.y );
      } else {
        ellipse( l.origin.position.x + 15, l.origin.position.y, 30, 30 );
      }
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
    ellipse( s.position.x, s.position.y, 40, 40 );
    fill( 255 );
    text( s.name, s.position.x - 11, s.position.y + 4 );
    
  }
  popMatrix();
  
  fill( 255 );
  text( 
    "" + vp1.isRunning() + 
    "\n" + vp1.isPlaying() + 
    "\n" + currentState.name, 
    15, 25 );
  
}

public void exit() {
  //vp1.suspend();
  super.exit();
}

public void mousePressed() {
  //vp1.nextCue();
}

public void keyPressed() {
 dispayMarkov = !dispayMarkov;
}

public void movieEvent(Movie m) { 
  m.read();
}