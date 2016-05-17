class State extends VideoPlayerListener {

  public String name;
  public PVector position;
  public color my_color;
  ArrayList<Link> links;
  float total_chance;
  VideoPlayer vid_play;
  int cueId;

  public void addlink(State s, float chance) {
    if ( s == null ) {
      return;
    }
    Link l = new Link(this, s, chance);
    links.add(l);
    total_chance += chance;
  }

  public State( String name, VideoPlayer vid_play, int i ) {
    this.name = name;
    links = new ArrayList<Link>();
    total_chance = 0;
    this.vid_play = vid_play;
    cueId = i;
    position = new PVector();
    //vid_play.activateCue(cue);
    //addlink(this, 1.0);
  }

  public void activateCue() {
    // println("State.activateCue " + cueId + " " + name);
    vid_play.activateCue(cueId, this);
  }

  public void timeOut() { 
    change();
  }

  public State change() {

    if ( links.size() == 0 ) { 
      vid_play.pause();
      return this;
    }

    float r = random( 0, total_chance );
    // println( r + " / " + total_chance );
    float c = 0;
    for ( Link l : links ) {
      c += l.chance;
      if ( c > r ) {
        State s = l.getTarget() ;
        s.activateCue();
        currentState = s;
        return s;
      }
    }
    return null;
  }
}