program p0201132303;

{cos sie pierdoli w kolizji z brickami, zderza sie z czyms czego nie ma}

{TODO:
 ***** BOT!
 ***   poprawic blad z kolizja (prawdopodobnie chujowo mapa zrobiona)
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
  zgl_sprite_2d
  {$ENDIF}
  ;

const
  ScreenX = 800;
  ScreenY = 600;
   maxC = 80;
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
  leci : boolean;
  bonusX, bonusY : single;
  bonusState :integer = 0;
  defLifes : integer = 2;
  ai :integer = 0;
  mainBackground :LongWord;
  bonusTime :integer = 0;
  bonusType,bonusDrawing:integer;
  counter,lifes,deskaVector,catch,remember,gun,bullet,menu,mPos,map:integer;
  kX,kY,speed,bulletX,bulletY : single;
  rect: zglTRect;

  pilkaSpeed:integer = 5;
  deskaSpeed:integer = 10;
  bulletSize :integer = 10;
  cir : zglTCircle;

  topBarHeight:integer = 25;

    spup,spdown,long,short,rzepa, bron,bulletTex,heart,mTex,sTex,statTex,wybTex,endTex,maTex: zglPTexture;

  bonusWide :integer = 50;
  brickW :integer = 80;
  brickH :integer = 15;
  bonusSpeed :single = 1.25;
  points:integer =0;
  username :string;
  players : array [1..10] of player;
  F : File Of player;
  Fb : file of brick;
   colors : array [0..2,0..2] of LongWord;
  wasSerce : integer;
  bricks : array [1..maxC] of brick;
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
var i,j,k,c,cl,los,wasSerce,heal :integer;

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

  Assign(fB,'data/maps/'+IntToStr(map)+'.dat');
  Reset(fB);
  for i := 1 to maxC do  Read(fB,bricks[i]);
  Close(fB);

  for i:=1 to maxC do writeln(bricks[i].x, ' ', bricks[i].y, ' ',   bricks[i].color, ' ',   bricks[i].health, ' ');

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
         if bricks[i].x > 0 then
            pr2d_rect(bricks[i].x,bricks[i].y,brickW,brickH,colors[bricks[i].health][bricks[i].color],255, PR2D_FILL);
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
         and (cir.cY+cir.Radius > y) and (cir.cY - cir.Radius < y+brickH)
         then
         begin

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
            else begin kX := (-1)*kX; cir.cX := cir.cX + kY;    end;
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
  end
  else if cir.cX-cir.Radius < 0 then
  begin
       cir.cX := cir.cX +2;
       kX := (-1)*kX;
  end
  else if cir.cY-cir.Radius < topBarHeight then
  begin
       kY := (-1)*kY;
  end
  else if cir.cY+cir.Radius >= screenY-rect.H then
  begin
       restoreVector;
       if (cir.cX < rect.X)  or (cir.cX > rect.X + rect.w)  then
       begin
          {pilka rozbila sie}
          leci := FALSE;
          Dec(lifes);
       end
       else
       begin
          {trafil w paletke}
          cir.cY := cir.cY -2;

          if catch =1 then
          begin
               leci := FALSE;
               remember :=1;
          end;

          srodek := round(rect.X + (rect.W / 2));
          odleglosc := abs(round(cir.cX) - srodek) /150 ;

          if odleglosc >= 1 then odleglosc := odleglosc - 0.05;
          if odleglosc < 0.2 then odleglosc := odleglosc-0.5;

          if deskaVector * kX < 0 then kX := (-1)*kX;
          { else if  (kX > 0) and (round(cir.cX) - srodek < 0) then kX:=(-1)*kX;
            else if  (kX < 0) and (round(cir.cX) - srodek > 0) then kX:=(-1)*kX;
            jesli z lewej strony to w lewo, jesli z prawej to w prawo }

          kX := abs(1+odleglosc) * kX;
          kY := (-1) * abs(1-odleglosc) *kY;
       end;
  end;
end;

procedure setDefaults;
begin
  leci := FALSE;
  lifes := 5;
  pilkaSpeed:=13;
  speed:=1.2;
  wasSerce := 0;
  map :=1;
  counter:=maxC;


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

  kX :=1;
  kY:=-1;

 { colors[1][0] :=  $00a300;
  colors[1][1] :=  $ffc40d;
  colors[1][2] :=  $ee1111;

  colors[2][0] :=  $1e7145;
  colors[2][1] :=  $e3a21a;
  colors[2][2] :=  $b91d47; }

  {colors[2][0] :=  $00a300;
  colors[2][1] :=  $ffc40d;
  colors[2][2] :=  $ee1111;

  colors[1][0] :=   $515151;
  colors[1][1] :=   $515151;
  colors[1][2] :=   $515151;  }

 { colors[2][0] :=  $00a300;
  colors[2][1] :=  $ffc40d;
  colors[2][2] :=  $ee1111;

  colors[1][0] :=   $00a300;
  colors[1][1] :=   $ffc40d;
  colors[1][2] :=   $ee1111;   }

  {colors[1][0] :=  $00a300;
  colors[1][1] :=  $ffc40d;
  colors[1][2] :=  $ee1111;

  colors[2][0] :=  $007d00;
  colors[2][1] :=  $c4970a;
  colors[2][2] :=  $b70d0d; }


  colors[2][0] :=  $4a4a4a;
  colors[2][1] :=  $4a4a4a;
  colors[2][2] :=  $4a4a4a;

  colors[1][0] :=  $00a300;
  colors[1][1] :=  $ffc40d;
  colors[1][2] :=  $ee1111;


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
  LoadGraph; {laduj grafike}

  InitGame;  {laduj poczatkowe ustawienia gry}
  InitMenu; {laduje menu}
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
     ssprite2d_Draw(texture, 0,0,800,600, 0);
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
     pr2d_rect(rect.X,rect.Y,rect.W,rect.H,$4a4a4a,255, PR2D_FILL);
end;
procedure drawTopBar;
begin
     pr2d_rect(0,0,ScreenX, topBarHeight,$4a4a4a,255, PR2D_FILL);
end;
procedure drawLifes;
var i :integer;
begin
      for i:=1 to lifes do
          pr2d_rect(3+(i-1)*(topBarHeight),2,(topBarHeight-5), (topBarHeight-5),$c11919,255, PR2D_FILL);
end;
procedure drawScore;
begin
   text_Draw( fnt, ScreenX - 40, 8, ' pkt');
   text_Draw( fnt, ScreenX - (numberOfDigits(points)*6)-45, 8, intToStr(points));
end;

procedure drawBall;
begin
   pr2d_circle( cir.cX,cir.cY, cir.Radius, $FFFFFF,255,32,PR2D_FILL);
   pr2d_circle( cir.cX,cir.cY, cir.Radius, $FFFFFF,255,32,PR2D_SMOOTH);
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

   drawBonus;  {rysuje bonusy spadajace}
   drawBullet; {rysuje kule z pistoletu}
   drawBonusState; {rysuje stan bonusow na belce }

end;
procedure mainPage();
{strona glowna menu}
begin
   initGame;

   setBackground(mainBackground);
   setBackgroundTexture(mTex);

   case mPos of
      1 : pr2d_Rect(415, 163, 15, 81, $00a300, 255, PR2D_FILL);
      2 : pr2d_Rect(415, 269, 15, 81, $ffc40d, 255, PR2D_FILL);
      3 : pr2d_Rect(415, 375, 15, 81, $2f2f2f, 255, PR2D_FILL);
      4 : pr2d_Rect(415, 484, 15, 81, $ee1111, 255, PR2D_FILL);
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

  {tutaj sortowanko mozna by poprawic, bo wstawiam jeden element reszta jest posortowana}
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
procedure Timer_Deska(dt:double);
begin
      deskaVector := 0;

      if (key_Down (K_Left)) and (rect.X > 0) then deskaVector := -3
      else if (key_Down (K_RIGHT)) and (rect.X+rect.W < screenX) then deskaVector :=3;
      rect.X:=rect.X+deskaVector;

       if NOT(leci) then
       begin
          if remember = 0 then cir.cX := rect.X+(rect.W/2) else cir.cX := cir.cX + deskaVector;
          cir.cY :=rect.Y-cir.Radius-1;
       end;

end;
procedure Timer_Bonus(dt:double);
begin
  if bonusState = 0 then
  begin
     if bonusType <> 0 then
     begin
          if (bonusY >= screenY-rect.H) and (bonusX >= rect.X)  and (bonusX <= rect.X + rect.w)  then
          begin
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
          case mPos of
               1 :menu :=1;
               2 :menu :=2;
               3 :menu :=3;
               4 :zgl_Exit();
          end;
  end   {glowna}
  else if  menu = 1 then  begin
      if (key_Press(K_G)) then
      begin
          menu :=6;
      end;
      if (key_Press(K_K)) then
      begin
           ai := 1;
           menu := 6;
      end;
  end {wybor}
  else if menu = 2 then begin if (key_Press(K_P)) then menu :=0 end {statystyki}

  else if  menu = 3 then  begin
      if (key_Press(K_Z)) then
      begin
           resetStats;
           menu :=0;
      end;
      if (key_Press(K_P)) then
      begin
           menu :=0;
      end;
  end {ustawienia}
  else if menu = 5 then begin
       key_BeginReadText( username, 16 );

       if key_Press( K_ENTER ) Then
       begin
            key_EndReadText();
            zapiszStaty;
            menu := 2; {statystyki}
       end;
  end {gameover}
  else if menu = 6 then begin
      if (key_Press(K_1)) then
      begin
           map:=1;
           menu :=4;
      end;
      if (key_Press(K_2)) then
      begin
           map:=2;
           menu :=4;
      end;
      if (key_Press(K_3)) then
      begin
           map:=3;
           menu :=4;
      end;
      setBricks;
      if (key_Press(K_P)) then
      begin
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
           if (key_Press(K_SPACE)) and NOT(leci) then leci :=TRUE;
           if (gun=1) and (bullet=0) and leci and (key_Press(K_SPACE))  then
           begin
                bulletY := rect.Y;
                bulletX := rect.X+(1/2)*rect.W;
                bullet :=1;
           end;

           if counter = 0 then
           begin
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
      if menu = 0 then zgL_exit()
      else menu :=0;
end;

Begin

  {$IFNDEF STATIC}
  zglLoad( libZenGL );
  {$ENDIF}

  timer_Add( @Timer, 16);
  timer_Add( @Timer_Input, 16);
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
