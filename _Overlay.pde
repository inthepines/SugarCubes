import java.lang.reflect.*;

/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * Overlay UI that indicates pattern control, etc. This will be moved
 * into the Processing library once it is stabilized and need not be
 * regularly modified.
 */
abstract class OverlayUI {
  protected final PFont titleFont = createFont("Myriad Pro", 10);
  protected final color titleColor = #AAAAAA;
  protected final PFont itemFont = createFont("Lucida Grande", 11);
  protected final PFont knobFont = titleFont;
  protected final int w = 140;
  protected final int leftPos;
  protected final int leftTextPos;
  protected final int lineHeight = 20;
  protected final int sectionSpacing = 12;
  protected final int controlSpacing = 18;
  protected final int tempoHeight = 20;
  protected final int knobSize = 28;
  protected final float knobIndent = .4;  
  protected final int knobSpacing = 6;
  protected final int knobLabelHeight = 14;
  protected final int scrollWidth = 14;
  protected final color lightBlue = #666699;
  protected final color lightGreen = #669966;
  
  private PImage logo;

  protected final int STATE_DEFAULT = 0;
  protected final int STATE_ACTIVE = 1;
  protected final int STATE_PENDING = 2;
  
  protected int[] pandaLeft = new int[pandaBoards.length];
  protected final int pandaWidth = 56;
  protected final int pandaHeight = 13;
  protected final int pandaTop = height-16;
  
  protected OverlayUI() {
    leftPos = width - w;
    leftTextPos = leftPos + 4;
    logo = loadImage("logo-sm.png");
  }
  
  protected void drawLogoAndBackground() {
    image(logo, 4, 4);
    stroke(color(0, 0, 100));
    // fill(color(0, 0, 50, 50)); // alpha is bad for perf
    fill(color(0, 0, 30));
    rect(leftPos-1, -1, w+2, height+2);
  }
  
  protected void drawToggleTip(String s) {
    fill(#999999);
    textFont(itemFont);
    textAlign(LEFT);
    text(s, leftTextPos, height-6);
  }
  
  protected void drawHelpTip() {
    textFont(itemFont);
    textAlign(RIGHT);
    text("Tap 'u' to restore UI", width-4, height-6);
  }

  public void drawFPS() {
    textFont(titleFont);
    textAlign(LEFT);
    fill(#666666);
    text("FPS: " + (((int)(frameRate * 10)) / 10.), 4, height-6);
    text("Target (-/+):", 50, height-6);
    fill(#000000);
    rect(104, height-16, 20, 13);
    fill(#666666);
    text("" + targetFramerate, 108, height-6);
    text("PandaOutput (p):", 134, height-6);
    int lPos = 214;
    int pi = 0;
    for (PandaDriver p : pandaBoards) {
      pandaLeft[pi++] = lPos;
      fill(p.enabled ? #666666 : #000000);
      rect(lPos, pandaTop, pandaWidth, pandaHeight);
      fill(p.enabled ? #000000 : #666666);
      text(p.ip, lPos + 4, height-6);
      lPos += 60;
    }

  }

  protected int drawObjectList(int yPos, String title, Object[] items, Method stateMethod) {
    int sz = (items != null) ? items.length : 0;
    return drawObjectList(yPos, title, items, stateMethod, sz, 0);
  }

  protected int drawObjectList(int yPos, String title, Object[] items, Method stateMethod, int scrollLength, int scrollPos) {
    return drawObjectList(yPos, title, items, classNameArray(items, null), stateMethod, scrollLength, scrollPos);
  }

  protected int drawObjectList(int yPos, String title, Object[] items, String[] names, Method stateMethod) {
    int sz = (items != null) ? items.length : 0;
    return drawObjectList(yPos, title, items, names, stateMethod, sz, 0);
  }
  
  protected int drawObjectList(int yPos, String title, Object[] items, String[] names, Method stateMethod, int scrollLength, int scrollPos) {
    noStroke();
    fill(titleColor);
    textFont(titleFont);
    textAlign(LEFT);
    text(title, leftTextPos, yPos += lineHeight);    
    if (items != null) {
      textFont(itemFont);
      color textColor;      
      boolean even = true;
      int yTop = yPos+6;
      for (int i = scrollPos; i < items.length && i < (scrollPos + scrollLength); ++i) {
        Object o = items[i];
        int state = STATE_DEFAULT;
        try {
           state = ((Integer) stateMethod.invoke(this, o)).intValue();
        } catch (Exception x) {
          throw new RuntimeException(x);
        }
        switch (state) {
          case STATE_ACTIVE:
            fill(lightGreen);
            textColor = #eeeeee;
            break;
          case STATE_PENDING:
            fill(lightBlue);
            textColor = color(0, 0, 75 + 15*sin(millis()/200.));;
            break;
          default:
            textColor = 0;
            fill(even ? #666666 : #777777);
            break;
        }
        rect(leftPos, yPos+6, w, lineHeight);
        fill(textColor);
        text(names[i], leftTextPos, yPos += lineHeight);
        even = !even;       
      }
      if ((scrollPos > 0) || (scrollLength < items.length)) {
        int yHere = yPos+6;
        noStroke();
        fill(color(0, 0, 0, 50));
        rect(leftPos + w - scrollWidth, yTop, scrollWidth, yHere - yTop);
        fill(#666666);
        rect(leftPos + w - scrollWidth + 2, yTop + (yHere-yTop) * (scrollPos / (float)items.length), scrollWidth - 4, (yHere - yTop) * (scrollLength / (float)items.length));
        
      }
      
    }
    return yPos;
  }
  
  protected String[] classNameArray(Object[] objects, String suffix) {
    if (objects == null) {
      return null;
    }
    String[] names = new String[objects.length];
    for (int i = 0; i < objects.length; ++i) {
      names[i] = className(objects[i], suffix);
    }
    return names;
  }
  
  protected String className(Object p, String suffix) {
    String s = p.getClass().getName();
    int li;
    if ((li = s.lastIndexOf(".")) > 0) {
      s = s.substring(li + 1);
    }
    if (s.indexOf("SugarCubes$") == 0) {
      s = s.substring("SugarCubes$".length());
    }
    if ((suffix != null) && ((li = s.indexOf(suffix)) != -1)) {
      s = s.substring(0, li);
    }
    return s;
  }  
  
  protected int objectClickIndex(int firstItemY) {
    return (mouseY - firstItemY) / lineHeight;
  }
  
  abstract public void draw();  
  abstract public void mousePressed();
  abstract public void mouseDragged();
  abstract public void mouseReleased();
  abstract public void mouseWheel(int delta);
}

/**
 * UI for control of patterns, transitions, effects.
 */
class ControlUI extends OverlayUI {  
  private final String[] patternNames;
  private final String[] transitionNames;
  private final String[] effectNames;
  
  private int firstPatternY;
  private int firstPatternKnobY;
  private int firstTransitionY;
  private int firstTransitionKnobY;
  private int firstEffectY;
  private int firstEffectKnobY;
  
  private final int PATTERN_LIST_LENGTH = 8;
  private int patternScrollPos = 0;

  private int tempoY;
  
  private Method patternStateMethod;
  private Method transitionStateMethod;
  private Method effectStateMethod;

  ControlUI() {    
    patternNames = classNameArray(patterns, "Pattern");
    transitionNames = classNameArray(transitions, "Transition");
    effectNames = classNameArray(effects, "Effect");

    try {
      patternStateMethod = getClass().getMethod("getState", LXPattern.class);
      effectStateMethod = getClass().getMethod("getState", LXEffect.class);
      transitionStateMethod = getClass().getMethod("getState", LXTransition.class);
    } catch (Exception x) {
      throw new RuntimeException(x);
    }    
  }
      
  public void draw() {    
    drawLogoAndBackground();
    int yPos = 0;
    firstPatternY = yPos + lineHeight + 6;
    yPos = drawObjectList(yPos, "PATTERN", patterns, patternNames, patternStateMethod, PATTERN_LIST_LENGTH, patternScrollPos);
    yPos += controlSpacing;
    firstPatternKnobY = yPos;
    int xPos = leftTextPos;
    for (int i = 0; i < glucose.NUM_PATTERN_KNOBS/2; ++i) {
      drawKnob(xPos, yPos, knobSize, glucose.patternKnobs.get(i));
      drawKnob(xPos, yPos + knobSize + knobSpacing + knobLabelHeight, knobSize, glucose.patternKnobs.get(glucose.NUM_PATTERN_KNOBS/2 + i));
      xPos += knobSize + knobSpacing;
    }
    yPos += 2*(knobSize + knobLabelHeight) + knobSpacing;

    yPos += sectionSpacing;
    firstTransitionY = yPos + lineHeight + 6;
    yPos = drawObjectList(yPos, "TRANSITION", transitions, transitionNames, transitionStateMethod);
    yPos += controlSpacing;
    firstTransitionKnobY = yPos;
    xPos = leftTextPos;
    for (VirtualTransitionKnob knob : glucose.transitionKnobs) {
      drawKnob(xPos, yPos, knobSize, knob);
      xPos += knobSize + knobSpacing;
    }
    yPos += knobSize + knobLabelHeight;
    
    yPos += sectionSpacing;
    firstEffectY = yPos + lineHeight + 6;
    yPos = drawObjectList(yPos, "FX", effects, effectNames, effectStateMethod);
    yPos += controlSpacing;
    firstEffectKnobY = yPos;    
    xPos = leftTextPos;
    for (VirtualEffectKnob knob : glucose.effectKnobs) {    
      drawKnob(xPos, yPos, knobSize, knob);
      xPos += knobSize + knobSpacing;
    }
    yPos += knobSize + knobLabelHeight;
    
    yPos += sectionSpacing;
    yPos = drawObjectList(yPos, "TEMPO", null, null, null);
    yPos += 6;
    tempoY = yPos;
    stroke(#111111);
    fill(tempoDown ? lightGreen : color(0, 0, 35 - 8*lx.tempo.rampf()));
    rect(leftPos + 4, yPos, w - 8, tempoHeight);
    fill(0);
    textAlign(CENTER);
    text("" + ((int)(lx.tempo.bpmf() * 100) / 100.), leftPos + w/2., yPos + tempoHeight - 6);
    yPos += tempoHeight;
    
    drawToggleTip("Tap 'u' to hide");
  }
  
  public LXParameter getOrNull(List<LXParameter> items, int index) {
    if (index < items.size()) {
      return items.get(index);
    }
    return null;
  }
  
  public int getState(LXPattern p) {
    if (p == lx.getPattern()) {
      return STATE_ACTIVE;
    } else if (p == lx.getNextPattern()) {
      return STATE_PENDING;
    }
    return STATE_DEFAULT;
  }
  
  public int getState(LXEffect e) {
    if (e.isEnabled()) {
      return STATE_PENDING;
    } else if (e == glucose.getSelectedEffect()) {
      return STATE_ACTIVE;
    }
    return STATE_DEFAULT;
  }
  
  public int getState(LXTransition t) {
    if (t == lx.getTransition()) {
      return STATE_PENDING;
    } else if (t == glucose.getSelectedTransition()) {
      return STATE_ACTIVE;
    }
    return STATE_DEFAULT;
  }
  
  private void drawKnob(int xPos, int yPos, int knobSize, LXParameter knob) {
    final float knobValue = knob.getValuef();
    String knobLabel = knob.getLabel();
    if (knobLabel == null) {
      knobLabel = "-";
    } else if (knobLabel.length() > 4) {
      knobLabel = knobLabel.substring(0, 4);
    }
    
    ellipseMode(CENTER);
    noStroke();
    fill(#222222);
    // For some reason this arc call really crushes drawing performance. Presumably
    // because openGL is drawing it and when we overlap the second set of arcs it
    // does a bunch of depth buffer intersection tests? Ellipse with a trapezoid cut out is faster
    // arc(xPos + knobSize/2, yPos + knobSize/2, knobSize, knobSize, HALF_PI + knobIndent, HALF_PI + knobIndent + (TWO_PI-2*knobIndent));
    ellipse(xPos + knobSize/2, yPos + knobSize/2, knobSize, knobSize);
    
    float endArc = HALF_PI + knobIndent + (TWO_PI-2*knobIndent)*knobValue;
    fill(lightGreen);
    arc(xPos + knobSize/2, yPos + knobSize/2, knobSize, knobSize, HALF_PI + knobIndent, endArc);
    
    // Mask notch out of knob
    fill(color(0, 0, 30));
    beginShape();
    vertex(xPos + knobSize/2, yPos + knobSize/2.);
    vertex(xPos + knobSize/2 - 6, yPos + knobSize);
    vertex(xPos + knobSize/2 + 6, yPos + knobSize);
    endShape();

    // Center circle of knob
    fill(#333333);
    ellipse(xPos + knobSize/2, yPos + knobSize/2, knobSize/2, knobSize/2);    
    
    fill(0);
    rect(xPos, yPos + knobSize + 2, knobSize, knobLabelHeight - 2);
    fill(#999999);
    textAlign(CENTER);
    textFont(knobFont);
    text(knobLabel, xPos + knobSize/2, yPos + knobSize + knobLabelHeight - 2);
  }
  
  private int patternKnobIndex = -1;
  private int transitionKnobIndex = -1;
  private int effectKnobIndex = -1;
  private boolean patternScrolling = false;
  
  private int lastY;
  private int releaseEffect = -1;
  private boolean tempoDown = false;

  public void mousePressed() {
    lastY = mouseY;
    patternKnobIndex = transitionKnobIndex = effectKnobIndex = -1;
    releaseEffect = -1;
    patternScrolling = false;
    
    for (int p = 0; p < pandaLeft.length; ++p) {
      int xp = pandaLeft[p];
      if ((mouseX >= xp) &&
          (mouseX < xp + pandaWidth) &&
          (mouseY >= pandaTop) &&
          (mouseY < pandaTop + pandaHeight)) {
          pandaBoards[p].toggle();
      }
    }
    
    if (mouseX < leftPos) {
      return;
    }
    
    if (mouseY > tempoY) {
      if (mouseY - tempoY < tempoHeight) {
        lx.tempo.tap();
        tempoDown = true;
      }
    } else if ((mouseY >= firstEffectKnobY) && (mouseY < firstEffectKnobY + knobSize + knobLabelHeight)) {
      effectKnobIndex = (mouseX - leftTextPos) / (knobSize + knobSpacing);
    } else if (mouseY > firstEffectY) {
      int effectIndex = objectClickIndex(firstEffectY);
      if (effectIndex < effects.length) {
        if (effects[effectIndex] == glucose.getSelectedEffect()) {
          effects[effectIndex].enable();
          releaseEffect = effectIndex;
        }
        glucose.setSelectedEffect(effectIndex);
      }
    } else if ((mouseY >= firstTransitionKnobY) && (mouseY < firstTransitionKnobY + knobSize + knobLabelHeight)) {
      transitionKnobIndex = (mouseX - leftTextPos) / (knobSize + knobSpacing);
    } else if (mouseY > firstTransitionY) {
      int transitionIndex = objectClickIndex(firstTransitionY);
      if (transitionIndex < transitions.length) {
        glucose.setSelectedTransition(transitionIndex);
      }
    } else if ((mouseY >= firstPatternKnobY) && (mouseY < firstPatternKnobY + 2*(knobSize+knobLabelHeight) + knobSpacing)) {
      patternKnobIndex = (mouseX - leftTextPos) / (knobSize + knobSpacing);
      if (mouseY >= firstPatternKnobY + knobSize + knobLabelHeight + knobSpacing) {
        patternKnobIndex += glucose.NUM_PATTERN_KNOBS / 2;
      }      
    } else if (mouseY > firstPatternY) {
      if ((patterns.length > PATTERN_LIST_LENGTH) && (mouseX > width - scrollWidth)) {
        patternScrolling = true;
      } else {
        int patternIndex = objectClickIndex(firstPatternY);
        if (patternIndex < patterns.length) {
          lx.goIndex(patternIndex + patternScrollPos);
        }
      }
    }
  }
  
  int scrolldy = 0;
  public void mouseDragged() {
    int dy = lastY - mouseY;
    scrolldy += dy;
    lastY = mouseY;
    if (patternKnobIndex >= 0 && patternKnobIndex < glucose.NUM_PATTERN_KNOBS) {
      LXParameter p = glucose.patternKnobs.get(patternKnobIndex);
      p.setValue(constrain(p.getValuef() + dy*.01, 0, 1));
    } else if (effectKnobIndex >= 0 && effectKnobIndex < glucose.NUM_EFFECT_KNOBS) {
      LXParameter p = glucose.effectKnobs.get(effectKnobIndex);
      p.setValue(constrain(p.getValuef() + dy*.01, 0, 1));
    } else if (transitionKnobIndex >= 0 && transitionKnobIndex < glucose.NUM_TRANSITION_KNOBS) {
      LXParameter p = glucose.transitionKnobs.get(transitionKnobIndex);
      p.setValue(constrain(p.getValuef() + dy*.01, 0, 1));
    } else if (patternScrolling) {
      int scroll = scrolldy / lineHeight;
      scrolldy = scrolldy % lineHeight;
      patternScrollPos = constrain(patternScrollPos - scroll, 0, patterns.length - PATTERN_LIST_LENGTH);
    }
  }
    
  public void mouseReleased() {
    patternScrolling = false;
    tempoDown = false;
    if (releaseEffect >= 0) {
      effects[releaseEffect].trigger();
      releaseEffect = -1;      
    }
  }
  
  public void mouseWheel(int delta) {
    if (mouseY > firstPatternY) {
      int patternIndex = objectClickIndex(firstPatternY);
      if (patternIndex < PATTERN_LIST_LENGTH) {
        patternScrollPos = constrain(patternScrollPos + delta, 0, patterns.length - PATTERN_LIST_LENGTH);
      }
    }
  }
  
}

/**
 * UI for control of mapping.
 */
class MappingUI extends OverlayUI {
  
  private MappingTool mappingTool;
  
  private final String MAPPING_MODE_ALL = "All On";
  private final String MAPPING_MODE_CHANNEL = "Channel";
  private final String MAPPING_MODE_SINGLE_CUBE = "Single Cube";
  
  private final String[] mappingModes = {
    MAPPING_MODE_ALL,
    MAPPING_MODE_CHANNEL,
    MAPPING_MODE_SINGLE_CUBE
  };
  private final Method mappingModeStateMethod;
  
  private final String CUBE_MODE_ALL = "All Strips";
  private final String CUBE_MODE_SINGLE_STRIP = "Single Strip";
  private final String CUBE_MODE_STRIP_PATTERN = "Strip Pattern";
  private final String[] cubeModes = {
    CUBE_MODE_ALL,
    CUBE_MODE_SINGLE_STRIP,
    CUBE_MODE_STRIP_PATTERN
  };
  private final Method cubeModeStateMethod;  

  private final String CHANNEL_MODE_RED = "Red";
  private final String CHANNEL_MODE_GREEN = "Green";
  private final String CHANNEL_MODE_BLUE = "Blue";
  private final String[] channelModes = {
    CHANNEL_MODE_RED,
    CHANNEL_MODE_GREEN,
    CHANNEL_MODE_BLUE,    
  };
  private final Method channelModeStateMethod;
  
  private int firstMappingY;
  private int firstCubeY;
  private int firstChannelY;
  private int channelFieldY;
  private int cubeFieldY;
  private int stripFieldY;
  
  private boolean dragCube;
  private boolean dragStrip;
  private boolean dragChannel;

  MappingUI(MappingTool mappingTool) {
    this.mappingTool = mappingTool;
    try {
      mappingModeStateMethod = getClass().getMethod("getMappingState", Object.class);
      channelModeStateMethod = getClass().getMethod("getChannelState", Object.class);
      cubeModeStateMethod = getClass().getMethod("getCubeState", Object.class);
    } catch (Exception x) {
      throw new RuntimeException(x);
    }    
  }
  
  public int getMappingState(Object mappingMode) {
    boolean active = false;
    if (mappingMode == MAPPING_MODE_ALL) {
      active = mappingTool.mappingMode == mappingTool.MAPPING_MODE_ALL;
    } else if (mappingMode == MAPPING_MODE_CHANNEL) {
      active = mappingTool.mappingMode == mappingTool.MAPPING_MODE_CHANNEL;
    } else if (mappingMode == MAPPING_MODE_SINGLE_CUBE) {
      active = mappingTool.mappingMode == mappingTool.MAPPING_MODE_SINGLE_CUBE;
    }
    return active ? STATE_ACTIVE : STATE_DEFAULT;
  }
  
  public int getChannelState(Object channelMode) {
    boolean active = false;
    if (channelMode == CHANNEL_MODE_RED) {
      active = mappingTool.channelModeRed;
    } else if (channelMode == CHANNEL_MODE_GREEN) {
      active = mappingTool.channelModeGreen;
    } else if (channelMode == CHANNEL_MODE_BLUE) {
      active = mappingTool.channelModeBlue;
    }
    return active ? STATE_ACTIVE : STATE_DEFAULT;
  }
  
  public int getCubeState(Object cubeMode) {
    boolean active = false;
    if (cubeMode == CUBE_MODE_ALL) {
      active = mappingTool.cubeMode == mappingTool.CUBE_MODE_ALL;
    } else if (cubeMode == CUBE_MODE_SINGLE_STRIP) {
      active = mappingTool.cubeMode == mappingTool.CUBE_MODE_SINGLE_STRIP;
    } else if (cubeMode == CUBE_MODE_STRIP_PATTERN) {
      active = mappingTool.cubeMode == mappingTool.CUBE_MODE_STRIP_PATTERN;
    }
    return active ? STATE_ACTIVE : STATE_DEFAULT;
  }
  
  public void draw() {
    drawLogoAndBackground();
    int yPos = 0;
    firstMappingY = yPos + lineHeight + 6;    
    yPos = drawObjectList(yPos, "MAPPING MODE", mappingModes, mappingModes, mappingModeStateMethod);
    yPos += sectionSpacing;

    firstCubeY = yPos + lineHeight + 6;    
    yPos = drawObjectList(yPos, "CUBE MODE", cubeModes, cubeModes, cubeModeStateMethod);
    yPos += sectionSpacing;

    firstChannelY = yPos + lineHeight + 6;    
    yPos = drawObjectList(yPos, "CHANNELS", channelModes, channelModes, channelModeStateMethod);    
    yPos += sectionSpacing;
    
    channelFieldY = yPos + lineHeight + 6;
    yPos = drawValueField(yPos, "CHANNEL ID", mappingTool.channelIndex + 1);
    yPos += sectionSpacing;

    cubeFieldY = yPos + lineHeight + 6;
    yPos = drawValueField(yPos, "CUBE ID", glucose.model.getRawIndexForCube(mappingTool.cubeIndex));
    yPos += sectionSpacing;

    stripFieldY = yPos + lineHeight + 6;
    yPos = drawValueField(yPos, "STRIP ID", mappingTool.stripIndex + 1);
    
    drawToggleTip("Tap 'm' to return");    
  }
  
  private int drawValueField(int yPos, String label, int value) {
    yPos += lineHeight;
    textAlign(LEFT);
    textFont(titleFont);
    fill(titleColor);
    text(label, leftTextPos, yPos);
    fill(0);
    yPos += 6;
    rect(leftTextPos, yPos, w-8, lineHeight);
    yPos += lineHeight;

    fill(#999999);
    textAlign(CENTER);
    textFont(itemFont);
    text("" + value, leftTextPos + (w-8)/2, yPos - 5);
    
    return yPos;    
  }

  private int lastY;
  
  public void mousePressed() {
    dragCube = dragStrip = dragChannel = false;
    lastY = mouseY;
    
    if (mouseX < leftPos) {
      return;
    }
    
    if (mouseY >= stripFieldY) {
      if (mouseY < stripFieldY + lineHeight) {
        dragStrip = true;
      }
    } else if (mouseY >= cubeFieldY) {
      if (mouseY < cubeFieldY + lineHeight) {
        dragCube = true;
      }
    } else if (mouseY >= channelFieldY) {
      if (mouseY < channelFieldY + lineHeight) {
        dragChannel = true;
      }
    } else if (mouseY >= firstChannelY) {
      int index = objectClickIndex(firstChannelY);
      switch (index) {
        case 0: mappingTool.channelModeRed = !mappingTool.channelModeRed; break;
        case 1: mappingTool.channelModeGreen = !mappingTool.channelModeGreen; break;
        case 2: mappingTool.channelModeBlue = !mappingTool.channelModeBlue; break;
      }
    } else if (mouseY >= firstCubeY) {
      int index = objectClickIndex(firstCubeY);
      switch (index) {
        case 0: mappingTool.cubeMode = mappingTool.CUBE_MODE_ALL; break;
        case 1: mappingTool.cubeMode = mappingTool.CUBE_MODE_SINGLE_STRIP; break;
        case 2: mappingTool.cubeMode = mappingTool.CUBE_MODE_STRIP_PATTERN; break;
      }
    } else if (mouseY >= firstMappingY) {
      int index = objectClickIndex(firstMappingY);
      switch (index) {
        case 0: mappingTool.mappingMode = mappingTool.MAPPING_MODE_ALL; break;
        case 1: mappingTool.mappingMode = mappingTool.MAPPING_MODE_CHANNEL; break;
        case 2: mappingTool.mappingMode = mappingTool.MAPPING_MODE_SINGLE_CUBE; break;
      }
    }
  }

  public void mouseReleased() {}
  public void mouseWheel(int delta) {}

  public void mouseDragged() {
    final int DRAG_THRESHOLD = 5;
    int dy = lastY - mouseY;
    if (abs(dy) >= DRAG_THRESHOLD) {
      lastY = mouseY;
      if (dragCube) {
        if (dy < 0) {
          mappingTool.decCube();
        } else {
          mappingTool.incCube();
        }
      } else if (dragStrip) {
        if (dy < 0) {
          mappingTool.decStrip();
        } else {
          mappingTool.incStrip();
        }
      } else if (dragChannel) {
        if (dy < 0) {
          mappingTool.decChannel();
        } else {
          mappingTool.incChannel();
        }
      }
    }
    
  }
}

class DebugUI {
  
  final int[][] channelList;
  final int debugX = 10;
  final int debugY = 42;
  final int debugXSpacing = 28;
  final int debugYSpacing = 22;
  final int[][] debugState = new int[17][6];
  
  final int DEBUG_STATE_ANIM = 0;
  final int DEBUG_STATE_WHITE = 1;
  final int DEBUG_STATE_OFF = 2;
  
  DebugUI(PandaMapping[] pandaMappings) {
    int totalChannels = pandaMappings.length * PandaMapping.CHANNELS_PER_BOARD;
    channelList = new int[totalChannels][];
    int channelIndex = 0;
    for (PandaMapping pm : pandaMappings) {
      for (int[] channel : pm.channelList) {
        channelList[channelIndex++] = channel;
      }
    }
    for (int i = 0; i < debugState.length; ++i) {
      for (int j = 0; j < debugState[i].length; ++j) {
        debugState[i][j] = DEBUG_STATE_ANIM;
      }
    }
  }
  
  void draw() {    
    noStroke();
    int xBase = debugX;
    int yPos = debugY;
    
    fill(color(0, 0, 0, 80));
    rect(4, 32, 172, 388);
    
    int channelNum = 0;
    for (int[] channel : channelList) {
      int xPos = xBase;
      drawNumBox(xPos, yPos, channelNum+1, debugState[channelNum][0]);
      
      boolean first = true;
      int cubeNum = 0;
      for (int cube : channel) {
        if (cube <= 0) {
          break;
        }
        xPos += debugXSpacing;
        if (first) {
          first = false;
        } else {
          stroke(#999999);          
          line(xPos - 12, yPos + 8, xPos, yPos + 8);
        }
        drawNumBox(xPos, yPos, cube, debugState[channelNum][cubeNum+1]);
        ++cubeNum;
      }
      
      yPos += debugYSpacing;
      ++channelNum;
    }
    drawNumBox(xBase, yPos, "A", debugState[channelNum][0]);
  }
  
  void drawNumBox(int xPos, int yPos, int label, int state) {
    drawNumBox(xPos, yPos, "" + label, state);
  }
  
  void drawNumBox(int xPos, int yPos, String label, int state) {
    noFill();
    color textColor = #cccccc;
    switch (state) {
      case DEBUG_STATE_ANIM:
        noStroke();
        fill(#880000);
        rect(xPos, yPos, 16, 8);
        fill(#000088);
        rect(xPos, yPos+8, 16, 8);
        noFill();
        stroke(textColor);
        rect(xPos, yPos, 16, 16); 
        break;
      case DEBUG_STATE_WHITE:
        stroke(textColor);
        fill(#e9e9e9);
        rect(xPos, yPos, 16, 16);
        textColor = #333333;
        break;
      case DEBUG_STATE_OFF:
        stroke(textColor);
        rect(xPos, yPos, 16, 16);
        break;
    }
    
    noStroke();
    fill(textColor);
    text(label, xPos + 2, yPos + 12);
  
  }
  
  void maskColors(color[] colors) {
    color white = #FFFFFF;
    color off = #000000;
    int channelIndex = 0;
    for (int[] channel : channelList) {
      int cubeIndex = 1;
      for (int rawCubeIndex : channel) {
        if (rawCubeIndex > 0) {
          int state = debugState[channelIndex][cubeIndex];
          if (state != DEBUG_STATE_ANIM) {
            color debugColor = (state == DEBUG_STATE_WHITE) ? white : off;
            Cube cube = glucose.model.getCubeByRawIndex(rawCubeIndex);
            for (Point p : cube.points) {
              colors[p.index] = debugColor;
            }
          }
        }
        ++cubeIndex;
      }
      ++channelIndex;
    }
  }
  
  void mousePressed() {
    int dx = (mouseX - debugX) / debugXSpacing;
    int dy = (mouseY - debugY) / debugYSpacing;
    if ((dy >= 0) && (dy < debugState.length)) {
      if ((dx >= 0) && (dx < debugState[dy].length)) {
        int newState = debugState[dy][dx] = (debugState[dy][dx] + 1) % 3;
        if (dy == 16) {
          for (int[] states : debugState) {
            for (int i = 0; i < states.length; ++i) {
              states[i] = newState;
            }
          }
        } else if (dx == 0) {
          for (int i = 0; i < debugState[dy].length; ++i) {
            debugState[dy][i] = newState;
          }
        }
      }
    }
  }    
}
