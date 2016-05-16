import processing.video.Movie;

public class VideoCue {

  private boolean initialised;
  // percent
  private float cuein;
  private float cueout;
  // time in sec, see Movie.time() for doc
  private float timein;
  private float timeout;
  private float speed;
  private boolean palindrome;
  
  public VideoCue() {
    initialised = false;
    cuein = 0;
    cueout = 0;
    timein = 0;
    timeout = 0;
    speed = 1;
    palindrome = false;
  }

  public VideoCue( VideoCue src ) {
    initialised = src.isInitialised();
    cuein = src.getCuein();
    cueout = src.getCueout();
    timein = src.getTimein();
    timeout = src.getTimeout();
    speed = src.getSpeed();
    palindrome = src.isPalindrome();
  }

  public boolean initPercent( Movie m, float cin, float cout, float speed, boolean palindrome ) {
    if ( m == null ) return false;
    float d = m.duration();
    return initTime( m, d * cin, d * cout, speed, palindrome );
  }

  public boolean initTime( Movie m, float tin, float tout, float speed, boolean palindrome ) {
    initialised = false;
    if ( m == null ) return false;
    if ( tin < 0 ) tin = 0;
    if ( tout < 0 ) tout = 0;
    if ( tin >= tout ) return false; 
    float d = m.duration();
    if ( d == 0 ) return false;
    if ( tin > d ) return false;
    if ( tout > d ) {
      System.err.println( "time out is greater than movie duration, auto adjustement! " + tout +  " <> " + d  );
      tout = d;
    }
    timein = tin;
    timeout = tout;
    cuein = tin / d;
    cueout = tout / d;
    this.speed = speed;
    this.palindrome = palindrome;
    initialised = true;
    return true;
  }

  public boolean isInitialised() {
    return initialised;
  }

  public float getCuein() {
    return cuein;
  }

  public float getCueout() {
    return cueout;
  }

  public float getTimein() {
    return timein;
  }

  public float getTimeout() {
    return timeout;
  }

  public boolean isPalindrome() {
    return palindrome;
  }

  public float getSpeed() {
    return speed;
  }

  public void setSpeed(float speed) {
    this.speed = speed;
  }
}