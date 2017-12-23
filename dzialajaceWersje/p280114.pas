program p280114;

{TODO:
 *     edytor map
}
{$DEFINE STATIC}

uses
  SysUtils,
  {$IFNDEF STATIC}
  zglHeader
  {$ELSE}
  Classes,
  zgl_main,
  zgl_types,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_keyboard,
  zgl_font,
  zgl_text,
  zgl_textures,
  zgl_textures_tga,
  zgl_textures_jpg, // JPG
  zgl_textures_png,
  zgl_primitives_2d,
  zgl_file,   zgl_resources,
  zgl_memory,
  zgl_utils,
  zgl_math_2d,
  zgl_sprite_2d,
  zgl_sound,
  zgl_sound_wav,
  zgl_sound_ogg
  {$ENDIF}
  ;

const
  ScreenX = 800;
  ScreenY = 600;
  maxC = 80;
  debug = false;
  type
    brick = record
          x:integer;
          y:integer;
          health:integer;
          color:LongWord;
          bonus:integer; {0 - brak,
                          1 - wieksza deska,
                          2- mniejsza deska,
                          3- szybsza pilka,
                          4-wolniejsza pilka,
                          5-rzepa
                          6-gun}
    end;
    player = record
          username : string[16];
          points : integer;
    end;



var
  dirRes     : String {$IFNDEF DARWIN} = 'data/' {$ENDIF};
  fnt,fntB,fntM       : zglPFont;
  leci,lock : boolean;
  dotheharlem:boolean = false;
  bonusX, bonusY : single;
  audio   : Integer;
  bonusState :integer = 0;
  defLifes : integer = 2;
  ai :integer = 0;
  mainBackground :LongWord;
  bonusTime :integer = 0;
  bonusType,bonusDrawing:integer;
  counter,lifes,catch,remember,gun,bullet,menu,mPos,map:integer;
  kX,kY,speed,bulletX,bulletY,deskaVector : single;
  rect: zglTRect;
  alphaTx:integer = 0;
  pilkaSpeed:integer = 5;
  deskaSpeed:integer = 10;
  bulletSize :integer = 10;
  cir : zglTCircle;
  harlemcount : integer = 0;
  lX, lY,lX2,lY2,b3,a3 : single;
  oX, oY,oX2,oY2 : single;
  wyborAI : single;
  wyborj  :integer;
  topBarHeight:integer = 25;
  spup,spdown,long,short,rzepa, bron,bulletTex,heart,mTex,sTex,statTex,wybTex,endTex,maTex: zglPTexture;
  bonusWide :integer = 50;
  brickW :integer = 80;
  brickH :integer = 15;
  bonusSpeed :single = 1.25;
  points:integer =0;
  username:string;
  players : array [1..10] of player;
  F : File Of player;
  Fb : file of brick;
  colors : array [0..2,0..2] of LongWord;
  wasSerce : integer;
  bricks : array [1..80] of brick;
procedure colSound;
begin
  audio := snd_PlayFile( 'data/col.ogg');
end;
procedure colDeskaSound;
begin
  audio := snd_PlayFile( 'data/woodhit.ogg');
end;
procedure colDeathSound;
begin
  audio := snd_PlayFile( 'data/punch.ogg');
end;
procedure completeSound;
begin
  audio := snd_PlayFile( 'data/complete.ogg');
end;
procedure bonusSound;
begin
  audio := snd_PlayFile( 'data/bonus.ogg');
end;
procedure shotSound;
begin
  audio := snd_PlayFile( 'data/shot.ogg');
end;
procedure harlemSound;
begin
  audio := snd_PlayFile( 'data/harlem.ogg');
end;

function areBricks:boolean;
var i :integer;
    r : boolean;
begin
     r := false;
     for i:=1 to maxC do
     begin
        if(bricks[i].health > 0) and (bricks[i].x > 0) and (bricks[i].x < screenX) then
        begin
          r := true;
          break;
        end;
     end;

     areBricks := r;

end;

function losujBonus():integer;
 var bonus,los :integer;
begin
            bonus := 0;
            if (random(1000) MOD 2 = 0) then begin
              los := random(8);
              if wasSerce = 0 then bonus:=los
              else
                  begin
                  if los = 7 then
                     repeat
                       los:=random(8);
                     until los <> 7;
                  bonus := los;
                  end;
              if los = 7 then wasSerce :=1;
            end;
   losujBonus := bonus;

end;

procedure setBricks;
var i{,j,k,c,cl,los,wasSerce,heal} :integer;
begin
    randomize;

    {dodac jakies sprytne czytanie z plikow }

  {  for i:= 1 to 8 do
    begin
        with bricks[i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := (10+brickH)+150 ;

           if (i = 4 )or (i = 5 )then begin color := 2; health :=2; end
           else begin x:=0;end;

           bonus := losujBonus();
        end;
    end;
    for i:= 1 to 8 do
    begin
        with bricks[8+i] do
        begin

           x := 40 + (brickW+10)*(i-1);
           y := 2*(10+brickH)+150 ;
           health := 2;
           color:=1;
            if (i = 4 )or (i = 5 )then begin color := 2; health :=2; end
           else begin x:=0;end;


            bonus := losujBonus();
        end;
    end;
    for i:= 1 to 8 do
    begin
        with bricks[16+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 3*(10+brickH)+150 ;
           health := 2;
           color:=0;
               if (i = 3 )or (i = 6 )then begin color := 2; health :=2;end
            else if (i = 4 )or (i = 5 )then begin color := 0; health :=1; end
            else begin x:=0;end;

           bonus := losujBonus();
        end;
    end;
     for i:= 1 to 8 do
    begin
        with bricks[24+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 4*(10+brickH)+150 ;
           health := 1;
           color:=0;

             if (i = 3 )or (i = 6 )then begin color := 2; health :=2;end
            else if (i = 4 )or (i = 5 )then begin color := 0; health :=1; end
            else begin x:=0;end;
        end;
    end;
    for i:= 1 to 8 do
    begin
        with bricks[32+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 5*(10+brickH)+150 ;
           health := 1;
           color:=0;
            if (i = 3 )or (i = 6 )then begin color := 0; health :=1;end
            else if (i = 4 )or (i = 5 )then begin color := 1; health :=1; end
            else if (i = 2 )or (i = 7 )then begin color := 2; health :=2; end
            else begin x:=0;end;
           bonus := losujBonus();
        end;
    end;
    for i:= 1 to 8 do
    begin
        with bricks[40+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 6*(10+brickH)+150 ;
           health := 1;
           color:=1;
           if (i = 3 )or (i = 6 )then begin color := 0; health :=1;end
            else if (i = 4 )or (i = 5 )then begin color := 1; health :=1; end
            else if (i = 2 )or (i = 7 )then begin color := 2; health :=2; end
            else begin x:=0;end;
        end;
    end;
    for i:= 1 to 8 do
    begin
        with bricks[48+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 7*(10+brickH)+150 ;
           health := 1;
           color:=1;
             if (i = 1 )or (i = 8 )then begin color:=2; health :=2; end
            else if (i = 2 )or (i = 7 )then begin health:=1;color:=0; end
            else begin health :=1; color := 1;end;
        end;
    end;
     for i:= 1 to 8 do
    begin
        with bricks[56+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 8*(10+brickH)+150 ;
           health := 1;
           color:=1;
               if (i = 1 )or (i = 8 )then begin color:=2; health :=2; end
           else if (i = 2 )or (i = 7 )then begin health:=1;color:=0; end
            else begin health :=1; color := 1;end;
        end;
    end;
      for i:= 1 to 8 do
    begin
        with bricks[64+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 9*(10+brickH)+150 ;
           health := 1;
           color:=2;
             if (i = 1 )or (i = 8 )then begin color:=2; health :=2; end
            else begin health :=1; color := 0;end;
           bonus := losujBonus();
        end;
    end;
        for i:= 1 to 8 do
    begin
        with bricks[72+i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := 10*(10+brickH)+150 ;
           health := 2;
           color:=2;

           bonus := losujBonus();
        end;
    end;
                }
   { j:=1;
    k:=1;

    c:= random(3);
    heal:=random(2)+1;
    wasSerce :=0;
    for i:=1 to maxC do
    begin
      with bricks[i] do
      begin
           x := 40 + (brickW+10)*(k-1);
           y := (j-1)*(10+brickH)+150 ;

           color:=c;

           if (random(1000) MOD 2 = 0) then begin
              los := random(8);
              if wasSerce = 0 then bonus:=los
              else
                  begin
                  if los = 7 then
                     repeat
                       los:=random(8);
                     until los <> 7;
                  bonus := los;
                  end;
              if los = 7 then wasSerce :=1;
           end;
           health := heal;
      end;
      Inc(k);
      if (i MOD 8 = 0) then begin Inc(j); k:=1;
           heal:=random(2)+1;
           repeat
             cl := random(3);
           until cl<>c;
           c:= cl;
      end;
    end;  }


 {Assign(fB,'data/maps/3.dat');
  Rewrite(fB);
  for i := 1 to maxC do  Write(fB,bricks[i]);
  Close(fB);}


  {for i:=1  to maxC do
    begin
        with bricks[i] do
        begin
           x := round(4*screenY/ 9);
           y := (10+brickH)+150 ;
           color:=1;
           health := 1;
        end;
    end;    }

   {  for i:= 1 to 8 do
    begin
        with bricks[i] do
        begin
           x := 40 + (brickW+10)*(i-1);
           y := (10+brickH)+150 ;
           health :=1 ;


        end;
    end;    }

  Assign(fB,'data/maps/'+IntToStr(map)+'.dat');
  Reset(fB);
  for i := 1 to maxC do  Read(fB,bricks[i]);
  Close(fB);

end;
procedure drawBonus();
begin
    if (bonusState = 0) then
       if(bonusY < screenY) then
       case bonusType of
            1 : ssprite2d_Draw(long, bonusX, bonusY, 20, 20, 0);
            2 : ssprite2d_Draw(short, bonusX, bonusY, 20, 20, 0);
            3 : ssprite2d_Draw(spup, bonusX, bonusY, 20, 20, 0);
            4 : ssprite2d_Draw(spdown, bonusX, bonusY, 20, 20, 0);
            5 : ssprite2d_Draw(rzepa, bonusX, bonusY, 20, 20, 0);
            6 : ssprite2d_Draw(bron, bonusX, bonusY, 20, 20, 0);
            7 : ssprite2d_Draw(heart, bonusX, bonusY, 20, 20, 0);
         end
       else begin bonusX := ScreenX + 1000;  bonusDrawing :=0; end;
end;
procedure setBonus(bonus:integer;posx,posy:single);
begin
   if (bonusState = 0) and (bonusDrawing = 0)  then
   begin
        bonusX := posx;
        bonusY := posy;
        bonusType := bonus;
        bonusDrawing :=1;
   end;
end;
 procedure drawBricks;
 var i:integer;
 begin
      for i:=1 to maxC do
      begin
         if (bricks[i].x > 0) and (bricks[i].health > 0) then
            pr2d_rect(bricks[i].x,bricks[i].y,brickW,brickH,colors[bricks[i].health][bricks[i].color],alphaTx , PR2D_FILL);
      end;
 end;
procedure restoreVector;
begin
   if kx < 0 then kX := -1 else kX:=1;
   if ky < 0 then kY := -1 else kY:=1;
end;

procedure checkCollisionBrick;
var i:integer;
begin
     for i:=1 to maxC do
     begin
       with bricks[i] do
       begin
         if (cir.cX-cir.Radius < x+brickW) and (cir.cX +cir.Radius > x)
         and (cir.cY+cir.Radius > y) and (cir.cY - cir.Radius < y+brickH) and (bricks[i].health > 0) and (bricks[i].x > 0)
         then
         begin
            lock := false;
            colSound;

            Dec(health);
            points := points + 100;
            if health = 0 then
            begin

             Dec(counter);
             if bonus <> 0 then setBonus(bonus,x+(1/2)*brickW, y+(1/2)*brickH);
              x:=ScreenX+5*brickW;
            end;
            restoreVector;
            if (cir.cY  >= y+brickH ) OR (cir.cY <= y)   then begin kY:=(-1)*kY ;cir.cY := cir.cY + kY; end
            else begin kX := (-1)*kX; cir.cX := cir.cX + kX;    end;
         end;
       end;
     end;
end;
procedure checkCollisionBullet;
var i:integer;
begin
     for i:=1 to maxC do
     begin

       with bricks[i] do
       begin
         if (bulletX-bulletSize < x+brickW) and (bulletX +bulletSize > x)
         and (bulletY+bulletSize > y) and (bulletY - bulletSize < y+brickH)
         then
         begin
            Dec(health);
            if health = 0 then
            begin
             Dec(counter);
             if bonus <> 0 then setBonus(bonus,x+(1/2)*brickW, y+(1/2)*brickH);
             x:=ScreenX+1000;
             bullet :=0;
            end;
         end;
       end;
     end;
end;
procedure checkCollisionWalls;
var
  srodek :integer;
  odleglosc:double;
begin
  odleglosc:=1;
  remember :=0;

  if cir.cX+cir.Radius > screenX then
  begin
       cir.cX := cir.cX -2;
       kX := (-1)*kX;
       colSound;
  end
  else if cir.cX-cir.Radius < 0 then
  begin
       cir.cX := cir.cX +2;
       kX := (-1)*kX;
       colSound;
  end
  else if cir.cY-cir.Radius < topBarHeight then
  begin
       kY := (-1)*kY;
       colSound;
  end
  else if cir.cY+cir.Radius >= screenY-rect.H then
  begin
       restoreVector;
       if (cir.cX < rect.X)  or (cir.cX > rect.X + rect.w)  then
       begin
          {pilka rozbila sie}
          colDeathSound;
          leci := FALSE;
          cir.cY := rect.Y - 3;
          Dec(lifes);
       end
       else
       begin
          colDeskaSound ;
          {trafil w paletke}
          cir.cY := cir.cY -5;
          lock := false;
          wyborAI := 0;

          if catch =1 then
          begin
               leci := FALSE;
               remember :=1;
          end;

          srodek := round(rect.X + (rect.W / 2));
          odleglosc := abs(cir.cX - srodek) /150 ;

          if odleglosc >= 1 then odleglosc := odleglosc - 0.05;
          if odleglosc < 0.2 then odleglosc := odleglosc-0.5;

          if (deskaVector * kX < 0) and (ai = 0) then kX := (-1)*kX;
          { else if  (kX > 0) and (round(cir.cX) - srodek < 0) then kX:=(-1)*kX;
            else if  (kX < 0) and (round(cir.cX) - srodek > 0) then kX:=(-1)*kX;
            jesli z lewej strony to w lewo, jesli z prawej to w prawo }

          kX := abs(1+odleglosc) * kX;
          kY := (-1) * abs(1-odleglosc) *kY;
       end;
  end;
end;

procedure setDefaults;
var r : single;
    i,s :integer;
begin
  leci := FALSE;

  pilkaSpeed:=13;
  speed:=1.2;
  wasSerce := 0;
  map :=1;


  counter:=maxC;

  lock := false;
  wyborAI := 0;

  catch :=0;
  gun:=0;
  bonusType :=0;

  username := '';
  mainBackground := $1d1d1d;

  rect.H:=10;
  rect.W:=150;
  rect.X:=400;
  rect.Y:=590;

  cir.cX:=400;
  cir.cY := 300;
  cir.Radius := 5;

  lX :=0;
  lY :=0;
  lX2:=0;
  lY2:=0;

  randomize;
  r := random(25);
  r := r / 100;

  i := random(50);
  kX :=1-r;
  kY:=-1+r;

  if(i MOD 2 = 0) then kX := (-1)*kX;

  colors[2][0] :=  $4a4a4a;
  colors[2][1] :=  $4a4a4a;
  colors[2][2] :=  $4a4a4a;
  colors[2][3] :=  $4a4a4a;

  colors[1][0] :=  $00a300;
  colors[1][1] :=  $ffc40d;
  colors[1][2] :=  $ee1111;
  colors[1][3] :=  $4a4a4a;


end;
procedure InitMenu;
begin
  menu :=0;
  mPos:=1;

end;

procedure InitGame;
begin
  setDefaults;
end;
procedure LoadGraph;
begin
  fnt := font_LoadFromFile( dirRes + 'font/Open Sans-Regular-10pt.zfi' );
  fntB := font_LoadFromFile( dirRes + 'font/Open Sans-Regular-36pt.zfi' );
  fntM := font_LoadFromFile( dirRes + 'font/Open Sans-Regular-24pt.zfi' );

  spup := tex_LoadFromFile('data\spup.png');
  spdown := tex_LoadFromFile( 'data\spdown.png');
  short := tex_LoadFromFile('data\short.png');
  long := tex_LoadFromFile( 'data\long.png');
  rzepa := tex_LoadFromFile('data\rzepa.png');
  bron := tex_LoadFromFile( 'data\gun.png');
  heart := tex_LoadFromFile( 'data\heart.png');
  bulletTex := tex_LoadFromFile( 'data\bullet.png');

  mTex := tex_LoadFromFile( 'data\main.png');
  sTex := tex_LoadFromFile( 'data\settings.png');
  wybTex := tex_LoadFromFile( 'data\wybor.png');
  statTex := tex_LoadFromFile( 'data\stats.png');
  endTex := tex_LoadFromFile( 'data\end.png');
  maTex := tex_LoadFromFile( 'data\maps.png');
end;

procedure Init;
begin
  {tylko raz ten init}

  LoadGraph; {laduj grafike}

  lifes := 5;

  InitGame;  {laduj poczatkowe ustawienia gry}
  InitMenu; {laduje menu}

   snd_Init();

end;
function numberOfDigits(x:integer):integer;
var digits :integer;
  begin
       digits := 0;
       while x > 0 do
       begin
          x := x DIV 10;
          Inc(digits);
       end;
       if digits = 0 then Inc(digits);
       numberOfDigits := digits;
  end;
procedure setBackground(color:LongWord);
begin
     pr2d_Rect(0, 0, ScreenX, ScreenY, color, 255, PR2D_FILL);
end;
procedure setBackgroundTexture(texture : zglPTexture);
begin
    ssprite2d_Draw(texture, 0,0,800,600,0, 0+alphaTx);
end;

procedure drawBonusState;
begin
     if bonusState <> 0 then
         case bonusType of
            1 : ssprite2d_Draw(long, ScreenX/2-20, 3, 20, 20, 0);
            2 : ssprite2d_Draw(short, ScreenX/2-20, 3, 20, 20, 0);
            3 : ssprite2d_Draw(spup, ScreenX/2-20, 3, 20, 20, 0);
            4 : ssprite2d_Draw(spdown, ScreenX/2-20, 3, 20, 20, 0);
            5 : ssprite2d_Draw(rzepa, ScreenX/2-20, 3, 20, 20, 0);
            6 : ssprite2d_Draw(bron, ScreenX/2-20, 3, 20, 20, 0);
            7 : ssprite2d_Draw(heart, ScreenX/2-20, 3, 20, 20, 0);
         end;
end;

procedure drawBullet;
begin
     if bullet = 1 then ssprite2d_Draw(bulletTex, bulletX, bulletY, 8, 12, 0);
end;
procedure drawDeske;
begin
     pr2d_rect(rect.X,rect.Y,rect.W,rect.H,$4a4a4a,alphaTx, PR2D_FILL);
end;
procedure drawTopBar;
begin
     pr2d_rect(0,0,ScreenX, topBarHeight,$4a4a4a,alphaTx, PR2D_FILL);
end;
procedure drawLifes;
var i :integer;
begin
      for i:=1 to lifes do
          pr2d_rect(3+(i-1)*(topBarHeight),2,(topBarHeight-5), (topBarHeight-5),$c11919,alphaTx, PR2D_FILL);
end;
procedure drawScore;
begin
   text_Draw( fnt, ScreenX - 40, 8, ' pkt');
   text_Draw( fnt, ScreenX - (numberOfDigits(points)*6)-45, 8, intToStr(points));
end;

procedure drawBall;
begin
   pr2d_circle( cir.cX,cir.cY, cir.Radius, $FFFFFF,alphaTx,32,PR2D_FILL);
   if(debug = true) then pr2d_circle( wyborAI, rect.Y,7, $ff0000,alphaTx,32,PR2D_FILL);
   pr2d_circle( cir.cX,cir.cY, cir.Radius, $FFFFFF,alphaTx,32,PR2D_SMOOTH);
end;

procedure DrawGame();
begin

   setBackground(mainBackground);
   drawTopBar; {rysuje belke gorna}

   drawBricks; {rysuje klocki}
   drawBall;   {rysuje pilke}
   drawDeske;  {rysuje deske}

   drawLifes;  {rysuje zycia}
   drawScore;  {rysuje ilosc pkt}

   if(ai=0) then drawBonus;  {rysuje bonusy spadajace}
   drawBullet; {rysuje kule z pistoletu}
   drawBonusState; {rysuje stan bonusow na belce }

   if(debug = true) then
   begin
       pr2d_Line( lX,lY,lX2,lY2, $ffffff,255 );
       pr2d_Line( oX,oY,oX2,oY2, $00ff00,255 );
   end;

end;
procedure mainPage();
{strona glowna menu}
begin
   initGame;

   setBackground(mainBackground);
   setBackgroundTexture(mTex);

   case mPos of
      1 : pr2d_Rect(415, 163, 15, 81, $00a300, alphaTx, PR2D_FILL);
      2 : pr2d_Rect(415, 269, 15, 81, $ffc40d, alphaTx, PR2D_FILL);
      3 : pr2d_Rect(415, 375, 15, 81, $2f2f2f, alphaTx, PR2D_FILL);
      4 : pr2d_Rect(415, 484, 15, 81, $ee1111, alphaTx, PR2D_FILL);
   end;
end;
procedure stats();
{ustawienia}
var i,k :integer;
    output:string;
begin
  setBackground(mainBackground);
  setBackgroundTexture(statTex);

  Assign(f,'data/statistics.dat');
  Reset(f);

  k:=1;
  While (EoF(f)=False) Do Begin
     Read(f,players[k]);
     Inc(k);
  End;
  Close(f);

  for i :=1 to k-1 do
  begin
    output := intToStr(i) + '. ' + players[i].username + ' ' + intToStr(players[i].points) + ' pkt';
    text_Draw( fntM, 201,180+(i-1)*40, output);
  end;
end;
procedure gameOver();
begin
   setBackground(mainBackground);
   setBackgroundTexture(endTex);

   username := key_GetText();
   text_Draw( fntB, 210,320, username);
end;
procedure resetStats();
begin
  Assign(f,'data/statistics.dat');
  Rewrite(f);
  Close(f);
end;
procedure zapiszStaty();
var nowy,x :player;
  i,j,k:integer;
begin
  nowy.username := username;
  nowy.points := points;

  Assign(f,'data/statistics.dat');
  Reset(f);

  k:=1;
  While (EoF(f)=False) Do Begin
     Read(f,players[k]);
     Inc(k);
     if k = 10 then break;
  End;


  players[k] := nowy;

  for j := k - 1 downto 1 do
  begin
    x := players[j];
    i := j+1;
    while (i <= k) and (x.points < players[i].points) do
    begin
      players[i - 1] := players[i];
      inc(i);
    end;
    players[i - 1] := x;
   end;

  Close(f);
  Rewrite(f);

  for i := 1 to k do  Write(f,players[i]);
  Close(f);
  Reset(f);
   i:=1;
     While Not (EoF(F)) Do
     Begin
        Read(F,players[i]);
        Inc(i);
     End;
   Close(f);
end;
procedure settings();
{ekran ustawien}
begin
   setBackground(mainBackground);
   setBackgroundTexture(sTex);
end;

procedure wybor();
{ ekran wybierania PC/HUMAN }
begin
   setBackground(mainBackground);
   setBackgroundTexture(wybTex);
end;
procedure chooseMap();
begin
  setBackground(mainBackground);
  setBackgroundTexture(maTex);
end;

procedure Draw();
begin
   if (alphaTx < 255) then Inc(alphaTx);

   case menu of
      0 : mainPage();
      1 : wybor();
      2 : stats();
      3 : settings();
      4 : drawGame;
      5 : gameOver();
      6 : chooseMap();
   end;

end;
procedure Timer_Gun(dt:double);
begin
     if bullet = 1 then
     begin
          bulletY:=bulletY-1;
          checkCollisionBullet;
     end;
end;
procedure Timer_Kulka(dt:double);
begin
     if leci then
     begin
          checkCollisionBrick;
          checkCollisionWalls;
          cir.cY := cir.cY + speed*kY;
          cir.cX := cir.cX + speed*kX;
     end;
end;
function bestVector():single;
var
  a, b,kX2,kY2,i,hitX, pX,pY,srodek,odleglosc:single;
  j:integer;
  LABEL koniec;
begin
  if kx < 0 then kX2 := -1 else kX2:=1;
  if ky < 0 then kY2 := -1 else kY2:=1;


  {prosta spadania}
  a:=kY/kX;
  b:=(cir.cY) - (a*(cir.cX));


  hitX := (rect.Y-cir.Radius - b) / a; {punkt uderzenia}

  if(kY > 0) and (hitX > 0) and (hitX < screenX) then {jesli pileczka spada i moze udezyc w ziemie}
  begin
    i := hitX-10;  {punkt poczatkowy do sprawdzania najlepszej pozycji odbicia}



    while(i+rect.W > hitX ) and (lock = false)  do
    {jesli sprawdzana pozycja jest jeszcze "na terenie" miejsca uderzenia i nie znaleziono wczesniej klocka}
    begin

      {obliczanie wektora po odbiciu, gdy paletka znajduje sie w pkt i}
      srodek := round(i+ (rect.W / 2));
      odleglosc := abs(hitX - srodek) /150 ;

      if odleglosc >= 1 then odleglosc := odleglosc - 0.05;
      if odleglosc < 0.2 then odleglosc := odleglosc-0.5;


      kX2 := abs(1+odleglosc) * kX2;
      kY2 := (-1) * abs(1-odleglosc) *kY2;
      {/koniec}

      {prosta po odbiciu}
      a3 := kY2/kX2;
      b3 := rect.Y - (a3*hitX);
      if(kX*a3 > 0) then a3 := (-1)*a3;


      if(i+rect.W < screenX) then
      for j:=maxC downto 1 do
      begin
           with bricks[j] do
           begin
              if  (x > 0) and (x < screenX) and (health > 0) then
              begin
                  pY := y;
                  pX := (pY - b3)/a3;

                  if(pX > x) and (pX < x +brickW) then
                  begin
                    wyborAI := i;
                    wyborj := j;
                    lock := true;
                    goto koniec;
                  end;
            end;
         end;
      end;

      i:=i-20;

    end; {end while }

    koniec:

    if(debug = true) then
    begin
     lX := cir.cX;
     lY := cir.cY;
     lX2 := hitX;
     lY2 := rect.Y;


     if(lock = true) then
     begin
      oX := hitX;
      oY := rect.Y;
      oX2 := -b3/a3;
      oY2 := 0;
      bricks[wyborj].color :=  random(3);
     end;

    end;

  end;

  if (lock = true) then
  begin
       if(wyborAI > rect.X  ) then
       begin
            bestVector := +3;
       end
       else if(wyborAI < rect.X ) then
       begin
            bestVector := -3;
       end;
  end
  else if (lock = false) then
  begin
       if(cir.cX > rect.X + rect.W/3) then
       begin
            bestVector := +3;
       end
       else if(cir.cX < rect.X + rect.W/3) then
       begin
            bestVector := -3;
       end;
  end;


end;

procedure Timer_Deska(dt:double);
var
  aiVector : single;
begin
      deskaVector := 0;

      if (ai = 1) and (menu=4) then
      begin
        aiVector := bestVector();

        if(aiVector < 0) and (rect.X > 0) then deskaVector := aiVector
        else if (aiVector > 0) and (rect.X+rect.W < screenX) then deskaVector := aiVector
        else deskaVector := 0;
        rect.X:=rect.X+deskaVector;

         if NOT(leci) then
           begin
                if remember = 0 then cir.cX := rect.X+(rect.W/2) else cir.cX := cir.cX + deskaVector;
                cir.cY :=rect.Y-cir.Radius-1;
                leci :=true;
           end;
      end
      else
      begin
           if (key_Down (K_Left)) and (rect.X > 0) then deskaVector := -3
           else if (key_Down (K_RIGHT)) and (rect.X+rect.W < screenX) then deskaVector :=3;
           rect.X:=rect.X+deskaVector;

           if NOT(leci) then
           begin
                if remember = 0 then cir.cX := rect.X+(rect.W/2) else cir.cX := cir.cX + deskaVector;
                cir.cY :=rect.Y-cir.Radius-1;
           end;
      end;
end;
procedure Timer_Bonus(dt:double);
begin
  if (bonusState = 0) and (ai=0) then
  begin
     if bonusType <> 0 then
     begin
          if (bonusY >= screenY-rect.H) and (bonusX >= rect.X)  and (bonusX <= rect.X + rect.w)  then
          begin
           bonusSound;
           bonusTime := 1000 { ~5sekund};
           bonusX := 20000;
           if bonusType = 1 then rect.W := rect.W + bonusWide
           else if bonusType = 2 then rect.W := rect.W - bonusWide
           else if bonusType = 3 then speed := bonusSpeed
           else if bonusType = 4 then speed := (1/bonusSpeed)
           else if bonusType = 5 then catch :=1
           else if bonusType = 6 then begin gun :=1; bullet:=0; end
           else if bonusType = 7 then begin Inc(lifes); bonusTime:=1;end;
           bonusState :=1;
            end
            else bonusY := bonusY +1;
     end;
  end
  else if bonusTime > 0 then
       begin
            dec(bonusTime);
            if BonusTime = 0 then
            begin
                 if bonusType = 1 then rect.W := rect.W - bonusWide
                 else if bonusType = 2 then rect.W := rect.W + bonusWide
                 else if bonusType = 3 then speed:=1
                 else if bonusType = 4 then speed:=1
                 else if bonusType = 5 then catch := 0
                 else if bonusType = 6 then gun :=0;
                 bonusState :=0;
                 bonusType :=0;
                 bonusDrawing :=0;
            end;
       end;
end;
procedure Timer_Input(dt:double);
begin
  if menu = 0 then
  begin

       if (key_Press(K_DOWN)) then
       begin
           if mPos < 4 then Inc(mPos)
          { else mPos := 1; }
       end
       else if (key_Press(K_UP)) then
       begin
           if mPos > 1 then Dec(mPos)
            {else mPos := 4;}
       end
       else if (key_Press(K_ENTER)) then
       begin
          alphaTx := 0;

          case mPos of
               1 :menu :=1;
               2 :menu :=2;
               3 :menu :=3;
               4 :zgl_Exit();
          end;
       end;
  end   {glowna}
  else if  menu = 1 then  begin
      if (key_Press(K_G)) then
      begin
          alphaTx := 0;
          points := 0;
          ai:=0;
          menu :=6;
      end;
      if (key_Press(K_K)) then
      begin
           alphaTx := 0;
           points := 0;
           ai := 1;
           menu := 6;
      end;
  end {wybor}
  else if menu = 2 then begin if (key_Press(K_P)) then begin menu :=0;alphaTx := 0; end; end {statystyki}

  else if  menu = 3 then  begin
      if (key_Press(K_Z)) then
      begin
           alphaTx := 0;
           resetStats;
           menu :=0;
      end;
      if (key_Press(K_P)) then
      begin
          alphaTx := 0;
           menu :=0;
      end;
  end {ustawienia}
  else if menu = 5 then begin
       key_BeginReadText( username, 16 );

       if key_Press( K_ENTER ) Then
       begin
            alphaTx := 0;
            key_EndReadText();
            zapiszStaty;
            menu := 2; {statystyki}
       end;
  end {gameover}
  else if menu = 6 then begin
      if (key_Press(K_1)) then
      begin
           alphaTx := 0;
           map:=1;
           menu :=4;
      end;
      if (key_Press(K_2)) then
      begin
           alphaTx := 0;
           map:=2;
           menu :=4;
      end;
      if (key_Press(K_3)) then
      begin
           alphaTx := 0;
           map:=3;
           menu :=4;
      end;
      setBricks;
      if (key_Press(K_P)) then
      begin
          alphaTx := 0;
           menu :=0;
      end;
  end; {mapki}
   key_ClearState();

end;

procedure Update( dt:double);
begin

      {wykonuje sie calyczas}
      if menu = 4 then
      begin
           if ai = 1 then
           begin
           if (key_Press(K_SPACE)) and NOT(leci) then leci :=TRUE;
                {if NOT(leci) then
                begin
                     cir.cX := cir.cX + deskaVector;
                     cir.cY :=rect.Y-cir.Radius-3;
                     leci := true;
                end;  }
           end
           else
           if (key_Press(K_SPACE)) and NOT(leci) then leci :=TRUE;
           if (gun=1) and (bullet=0) and leci and (key_Press(K_SPACE))  then
           begin
                shotSound;
                bulletY := rect.Y;
                bulletX := rect.X+(1/2)*rect.W;
                bullet :=1;
           end;

           if areBricks = false then
           begin
              completeSound;
              leci := FALSE;
              InitGame;
              menu := 6;
           end;
      end;

      if lifes = 0 then
      begin
           lifes := defLifes;
           leci := FALSE;
           menu:= 5;
      end;

end;

procedure Timer;
begin
  if (key_Press( K_Q)) then
  begin
      alphaTx := 0;
      if menu = 0 then zgL_exit()
      else menu :=0;
  end;
  if (key_Press( K_H)) then dotheharlem:=true;



end;

procedure Timer_Harlem;
var  i,x : integer;
begin
     randomize;
     if dotheharlem = true then
     begin
          if harlemcount = 0 then  harlemSound;


            {for i:=1 to maxC do
            begin
              if (bricks[i].x > 0) and (bricks[i].x < screenx) then
              begin
                bricks[i].x := bricks[i].x - random(10);
                bricks[i].x := bricks[i].y - random(10);
              end;
            end;  }
            rect.Y := rect.Y - random(5);
            rect.X := rect.X - random(3);
            if(harlemcount MOD 3 = 0) then
            begin
                 rect.Y := 590;
                 rect.X := 400;
            end;

          if (harlemcount = 967) then setbricks;

          if (harlemcount > 967) then
          begin

            for i:=1 to maxC do
            begin
              if (bricks[i].x > 0) and (bricks[i].x < screenx) then
              begin
                bricks[i].x := bricks[i].x - random(5);
                bricks[i].y := bricks[i].y - random(7);
                if(harlemcount MOD 5 = 0) then bricks[i].color := random(3);
              end;
            end;

            if(harlemcount MOD 3 = 0) then setbricks;

          end;

          if(harlemcount = 1860) then dotheharlem := false;
          Inc(harlemcount);


     end;
end;
Begin
   randomize;
  {$IFNDEF STATIC}
  zglLoad( libZenGL );
  {$ENDIF}
  timer_Add( @Timer, 16);
  timer_Add( @Timer_Input, 16);
  timer_Add( @Timer_Harlem, 16);
  timer_Add( @Timer_Bonus, 5);
  timer_Add( @Timer_Gun, 5);
  timer_Add( @Timer_Kulka, pilkaSpeed);
  timer_Add( @Timer_Deska, deskaSpeed);


  zgl_Reg( SYS_LOAD, @Init );

  zgl_Reg( SYS_UPDATE, @Update);

  zgl_Reg( SYS_DRAW, @Draw );

  wnd_SetCaption( 'Arkanoid' );

  wnd_ShowCursor( FALSE );

  scr_SetOptions( ScreenX, ScreenY, REFRESH_MAXIMUM, FALSE, FALSE );

  zgl_Init();
End.
