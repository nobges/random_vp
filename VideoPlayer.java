import java.util.ArrayList;

import processing.core.PApplet;
import processing.video.Movie;


public class VideoPlayer extends Thread {

  private boolean locked;
  private boolean running;
  private long runtime;
  private String path;
  private PApplet parent;
  private Movie mov;
  private float duration;
  private boolean playing;
  private boolean verify_time_in;
  private boolean jump_request;

  private VideoCue current_cue;
  private VideoPlayerListener listener;
  private ArrayList< VideoCue > cues;

  public VideoPlayer( PApplet parent, String path ) {
    locked = false;
    running = false;
    playing = false;
    verify_time_in = false;
    jump_request = false;
    runtime = 0;
    this.parent = parent;  
    this.path = path;
    mov = new Movie( parent, path );
    mov.loop();
    cues = new ArrayList< VideoCue >();
    current_cue = null;
    listener = null;
  }

  public boolean addCue( float timein, float timeout ) {
    return addCue( timein, timeout, 1 );
  }

  public boolean addCue( float timein, float timeout, float speed ) {
    VideoCue vc = new VideoCue();
    boolean success = vc.initTime( mov, timein, timeout, speed, false );
    if ( success ) {
      cues.add( vc );
    }
    return success;
  }

  synchronized public void draw() {
    lock();
    parent.image( mov, 0, 0, 1280, 720 );
    unlock();
  }

  public void lock() {
    while ( locked ) {
      try {
        Thread.sleep( 1 );
      } 
      catch (InterruptedException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
    }
    locked = true;
  }

  public void unlock() {
    locked = false;
  }

  public void start() {
    if ( !running ) {
      super.start();
    }
    running = true;
    runtime = System.currentTimeMillis();
    duration = mov.duration();
    mov.loop();
    play();
  }
  
  public void dispose() {
    lock();
    running = false;
    unlock();
    mov.stop();
    super.stop();
  }

  public void run() {
    
    while ( running ) {
      
      if ( playing ) {
        
        try {
        
          lock();
          
          long deltatime = System.currentTimeMillis() - runtime;
          
          if ( current_cue == null ) {

          } else {
            
            if ( mov.isLoaded()  || mov.isModified() ) {
            
              float t = mov.time();
              float cs = current_cue.getSpeed();

              //if ( verify_time_in ) {
              //  System.err.println( "run() " + verify_time_in + ", time: " + t + ", cue in: " + current_cue.getTimein() );
              //}

              if ( 
                ( t < current_cue.getTimein() || verify_time_in ) &&
                !jump_request
                ) {
              
                //System.err.println( "not good, let's jump to " + current_cue.getTimein() + " <> " + t + " verify? " + verify_time_in  );
                mov.jump( current_cue.getTimein() );
                if ( cs < 0 ) current_cue.setSpeed( cs * -1 );
                mov.speed( current_cue.getSpeed() );
                verify_time_in = false;
                jump_request = true;
              
              } else if ( !verify_time_in && t >= current_cue.getTimeout() ) {
                
                //parent.println("timeOut");
                if (listener != null) {
                  listener.timeOut();
                }
                
              } else if ( t >= current_cue.getTimein() && t < current_cue.getTimeout() ) {
                
                verify_time_in = false;
                jump_request = false;
                
              }
              
            }
          }
          
          unlock();
        
        } catch ( Exception e ) {

          // killing thread
          running = false;
          return;
          
        }
        
      }
      
      try {
        
        Thread.sleep( 2 );
      
      } catch (InterruptedException e) {
        
        // TODO Auto-generated catch block
        e.printStackTrace();
      
      }
      
      runtime = System.currentTimeMillis();
      
    }
      
  }

  public int getCueSize() {
    return cues.size();
  }

  public boolean activateCue( int i, VideoPlayerListener l ) {
    activateCue(i);
    listener = l;
    return true;
  }
  public boolean activateCue( int i ) {
    if ( i < 0 ) {
      current_cue =null;
      return true;
    }
    // parent.println("VideoPlayer.activateCue " + i);
    if ( i >= cues.size() ) return false;
    current_cue = cues.get( i );
    verify_time_in = true;
    //System.err.println( "verify_time_in" );
    return true;
  }

  public boolean nextCue() {
    if ( cues.size() == 0 ) return false;
    if ( current_cue == null ) {
      current_cue = cues.get( 0 );
      return true;
    }
    for ( int  i = 0; i < cues.size (); ++i ) {
      if ( cues.get( i ) == current_cue ) {
        if ( i < cues.size() - 1 ) { 
          current_cue = cues.get( i + 1 );
          return true;
        } else { 
          current_cue = cues.get( 0 );
          return true;
        }
      }
    }
    return false;
  }

  public VideoCue getCurrentCue() {
    if ( current_cue == null ) return null;
    // no way to get your hands on the real object!
    return new VideoCue( current_cue );
  }

  public void volume(float v) {
    mov.volume(v);
  }

  public float duration() {
    return mov.duration();
  }

  public float time() {
    return mov.time();
  }

  public void play() {
    playing = true;
    mov.play();
  }

  public void pause() {
    playing = false;
    mov.pause();
  }


  public boolean isRunning() {
    return running;
  }

  public boolean isLoaded() {
    return mov.isLoaded();
  }
  
  public boolean isPlaying() {
    return playing;
  }
  
  public boolean isPause() {
    if ( mov.isLoaded() && !playing ) {
      return true;
    }
    return false;
  }
  
}