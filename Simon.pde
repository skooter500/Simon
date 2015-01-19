import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;
Oscil square; 

void setup()
{
  size(500, 500);
  halfWidth = width / 2;
  halfHeight = height / 2;
  cellX[0] = cellX[2] = 0; 
  cellX[1] = cellX[3] = halfWidth;

  cellY[0] = cellY[1] = 0; 
  cellY[2] = cellY[3] = halfHeight;
  
  minim = new Minim(this);
  out = minim.getLineOut();
  square = new Oscil(0, 0.5f, Waves.SQUARE);
  square.patch(out);
  addSequence();    
  current = 0;
  
}
ArrayList<Integer> sequence = new ArrayList<Integer>();

int current = 0;
int clicked = -1;
float halfWidth;
float halfHeight;

int gameMode;
int interval = 30;
int frameSeq = 0;
color[] colours = {
            color(0, 255, 0)
            , color(255, 0, 0)
            , color(0, 0, 255)
            , color(255, 255, 0)
          };         
float[] cellX = new float[4];
float[] cellY = new float[4];

float[] frequencies = {415, 310, 252, 209, 47};

void addSequence()
{
  sequence.add(new Integer((int) random(0, 4)));
}

void clearSequence()
{
  sequence.clear();
}

int whichCell()
{
  for(int i = 0 ; i < 4 ; i ++)
  {
    if (mouseX >= cellX[i] && mouseX < cellX[i] + halfWidth && mouseY >= cellY[i] && mouseY < cellY[i] + halfHeight)
    {
      return i;
    }    
  }
  // Should not get here...
  return -1;
}

void mousePressed()
{
  if (gameMode == 1)
  {
    clicked = whichCell();    
    dud = (clicked != sequence.get(current).intValue());
  }
}

boolean dud;

void mouseReleased()
{
  dud = false;
  if (gameMode == 1)
  {
    if (clicked == sequence.get(current).intValue())
    {
      current ++;
      clicked = -1;
      if (current == sequence.size())
      {
        current = 0;
        gameMode = 0;
        frameSeq = 0;
        gapFrames = 10;
        addSequence();
      }
    }
    else
    {
      current = 0;
      frameSeq = 0;
      gameMode = 0;
      clicked = -1;
      
      clearSequence();
      addSequence();      
    }
  }
}

void drawBoard(int highlighted)
{
  boolean high = false;
  for(int i = 0 ; i < 4 ; i ++)
  {
    if (i == highlighted)
    {
      stroke(colours[i]);
      fill(colours[i]);
      if (dud)
      {
        square.setFrequency(frequencies[4]);
      }
      else
      {
        square.setFrequency(frequencies[i]);
      }      
      high = true;      
    }
    else
    {
      float dim = 0.5f;
      stroke(red(colours[i]) * dim, green(colours[i]) * dim, blue(colours[i]) * dim);
      fill(red(colours[i]) * dim, green(colours[i]) * dim, blue(colours[i]) * dim);      
    }    
    rect(cellX[i], cellY[i], halfWidth, halfHeight);
  }  
  
  if (highlighted == 4)
  {
    square.setFrequency(frequencies[4]);
  }
  if (high || highlighted == 4)
  {
    square.setAmplitude(0.5f);
  }
  else
  {
    square.setAmplitude(0.0f);
  }
}

int gapFrames = 0;

void draw()
{  
  frameSeq ++;
  // Paulse the audio for a certain number of frames?
  if (gapFrames > 0)
  {
    drawBoard(-1);
    square.setAmplitude(0);
    gapFrames --;
    frameSeq = 0;
    return;
  }  
  // Playback of sequence 
  if (gameMode == 0)
  {    
    if (frameSeq % interval == 0)
    {        
      current ++;      
      if (current == sequence.size())
      {
        gameMode = 1;
        current = 0;
        gapFrames = 10;
        return;
      }
      else
      {
        if (sequence.get(current).intValue() == sequence.get(current - 1).intValue())
        {
          gapFrames = 10;
        }
      }
    }    
    drawBoard(sequence.get(current));
  }
  // User play back 
  if (gameMode == 1)
  {
    drawBoard(clicked);
  }
}
