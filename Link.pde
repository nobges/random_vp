class Link {
  private State origin;
  private State target;
  float chance;

  public Link(State o, State t, float c){
    this.origin = o;
    this.target = t;
    this.chance = c;
  }

  public State getTarget() 
  { 
    return target;
  }
}