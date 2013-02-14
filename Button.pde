class Button
{
  PVector position;
  PVector buttonSize;
  
  boolean pressed = false;
  boolean selected = false;
  
  float timeSinceLastTouch;
  float pressedTimeout = 250; // milliseconds
  
  color fillColor = color(25);
  color strokeColor = color(50);
  
  color pressedFillColor = color(10, 228, 228 );
  color selectedFillColor = color(10, 250, 200 );
  
  PFont font;
  String buttonText = "";
  boolean hasText = false;
  
  Button( int xPos, int yPos, int width, int height )
  {
    position = new PVector( xPos, yPos );
    buttonSize = new PVector( width, height );
  }// CTOR
 
  void draw()
  {
    //if( pressed )
    //  fill(pressedFillColor);
    //else if( selected )
    //  fill(selectedFillColor);
    //else
    fill(fillColor);
    
    if( pressed )
      stroke(pressedFillColor);
    else if( selected )
      stroke(selectedFillColor);
    else
      stroke(strokeColor);
    strokeWeight(3);
    rect( position.x, position.y, buttonSize.x, buttonSize.y );
    
    if( hasText )
    {
      fill(0);
      textAlign(CENTER);
      text( buttonText, position.x + buttonSize.x/2, position.y  + buttonSize.y/2 + 5);
      textAlign(LEFT);
    }
    
    timeSinceLastTouch = millis();
    
    if( pressed && timeSinceLastTouch > pressedTimeout )
      pressed = false;
  }// draw
  
  boolean isPressed( int xPos, int yPos )
  {
    if( xPos >= position.x && xPos <= position.x + buttonSize.x && yPos >= position.y && yPos <= position.y + buttonSize.y )
    {
      timeSinceLastTouch = 0;
      pressed = true;
      selected = !selected;
      return true;
    }
    
    pressed = false;
    return false;
  }// isPressed
  
  void setText( String text, PFont font, int fontSize )
  {
    buttonText = text;
    this.font = font;
    textFont( font, fontSize );
    hasText = true;
  }
}// class
