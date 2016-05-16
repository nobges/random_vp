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

  private VideoCue current_cue;
  private VideoPlayerListener listener;
  private ArrayList< VideoCue > cues;

  public VideoPlayer( PApplet parent, String path ) {
    locked = false;
    running = false;
    playing = false;
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


  //	public Movie getMov() {
  //		return mov;
  //	}

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
    super.start();
    running = true;
    runtime = System.currentTimeMillis();
    duration = mov.duration();
    mov.loop();
    mov.play();
  }

  public void run() {
    while ( running ) {
      if (!playing) {
        try {
          lock();
          long deltatime = System.currentTimeMillis() - runtime;
          if ( current_cue == null ) {
            // normal playhead
            // 					System.out.println( mov.time() + " / " + duration );
          } else {
            if ( mov.isLoaded()  || mov.isModified() ) {
              //						System.out.println( mov.time() + " / " + duration );
              float t = mov.time();
              float cs = current_cue.getSpeed();
              if ( t < current_cue.getTimein() ) {
                mov.jump( current_cue.getTimein() );
                if ( cs < 0 ) current_cue.setSpeed( cs * -1 );
                mov.speed( current_cue.getSpeed() );
              } else if ( t >= current_cue.getTimeout() ) {
                //parent.println("timeOut");
                if (listener != null) {
                  listener.timeOut();
                }
                //if ( current_cue.isPalindrome() && cs > 0 ) {
                //  current_cue.setSpeed( cs * -1 );
                //  mov.speed( current_cue.getSpeed() );
                //} else if ( !current_cue.isPalindrome() ) {
                //  mov.jump( current_cue.getTimein() );
                //}
                //							System.out.println( "jumping to " + current_cue.getTimein() );
              }
            }
          }
          unlock();
        } 
        catch ( Exception e ) {

          // killing thread
          running = false;
          return;
        }
      }
      try {
        Thread.sleep( 20 );
      } 
      catch (InterruptedException e) {
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
    if (i < 0){
      current_cue =null;
      return true;
    }
    parent.println("VideoPlayer.activateCue " + i);
    if ( i >= cues.size() ) return false;
    current_cue = cues.get( i );
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

  /*public VideoCue back(){
   if(current_cue <= cueout){
   return this;
   } else {
   
   }*/

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

  public boolean isLoaded() {
    return mov.isLoaded();
  }
}