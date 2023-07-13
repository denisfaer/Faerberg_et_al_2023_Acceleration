program stage_curves;

const
  k = 125;
  red = 30;
  smoothk = 10000;
  trouble = TRUE;

var
  fin, fout: text;
  i, j, y, cnt, st: integer;
  s: string;
  r: real;
  molt: array[1..k, 1..4]of integer;
  step: array[1..k, 1..4]of integer;
  curve: array[1..k + 1, 1..4, 0..100] of real;

begin
  //reset curve array
  for i := 1 to k + 1 do
    for y := 1 to 4 do
      for j := 0 to 100 do
        curve[i, y, j] := 0;
  //read stage boundaries [lethargus midpoints]
  assign(fin, 'globmin.csv');
  reset(fin);
  readln(fin, s);
  if(trouble) then
    writeln(s);
  for j := 1 to k do
  begin
    readln(fin, s);
    r := StrToFloat(copy(s, 1, pos(',', s, 1) - 1));
    molt[j, 1] := round(r * 6);
    delete(s, 1, pos(',', s, 1));
    r := StrToFloat(copy(s, 1, pos(',', s, 1) - 1));
    molt[j, 2] := round(r * 6);
    delete(s, 1, pos(',', s, 1));
    r := StrToFloat(copy(s, 1, pos(',', s, 1) - 1));
    molt[j, 3] := round(r * 6);
    delete(s, 1, pos(',', s, 1));
    molt[j, 4] := round(StrToFloat(s) * 6);
    if(trouble) then
      writeln(molt[j, 1], ' ', molt[j, 2], ' ', molt[j, 3], ' ', molt[j, 4]);
  end;
  close(fin);
  //create 1/100th stage steps
  for j := 1 to k do
  begin
    step[j, 1] := trunc(molt[j, 1] / 100);
    step[j, 2] := trunc((molt[j, 2] - molt[j, 1]) / 100);
    step[j, 3] := trunc((molt[j, 3] - molt[j, 2]) / 100);
    step[j, 4] := trunc((molt[j, 4] - molt[j, 3]) / 100);
  end;
  //create individual stage curves
  for j := 1 to k do
  begin
    assign(fin, InttoStr(j) + 're' + InttoStr(red) + 'smooth' + IntToStr(round(smoothk / red)) + '.csv');
    reset(fin);
    //create L1 curve
    readln(fin, r);
    cnt := 1;
    curve[j, 1, 0] := r;
    while(cnt < molt[j, 1]) do
    begin
      readln(fin, r);
      inc(cnt);
      if((cnt mod step[j, 1]) = 0) then
      begin
        st := cnt div step[j, 1];
        if(st <= 100) then
          curve[j, 1, st] := r;
      end;
    end;
    //create L2 curve
    curve[j, 2, 0] := r;
    while(cnt < molt[j, 2]) do
    begin
      readln(fin, r);
      inc(cnt);
      if(((cnt - molt[j, 1]) mod step[j, 2]) = 0) then
      begin
        st := (cnt - molt[j, 1]) div step[j, 2];
        if(st <= 100) then
          curve[j, 2, st] := r;
      end;
    end;
    //create L3 curve
    curve[j, 3, 0] := r;
    while(cnt < molt[j, 3]) do
    begin
      readln(fin, r);
      inc(cnt);
      if(((cnt - molt[j, 2]) mod step[j, 3]) = 0) then
      begin
        st := (cnt - molt[j, 2]) div step[j, 3];
        if(st <= 100) then
          curve[j, 3, st] := r;
      end;
    end;
    //create L4 curve
    curve[j, 4, 0] := r;
    while(cnt < molt[j, 4]) do
    begin
      readln(fin, r);
      inc(cnt);
      if(((cnt - molt[j, 3]) mod step[j, 4]) = 0) then
      begin
        st := (cnt - molt[j, 3]) div step[j, 4];
        if(st <= 100) then
          curve[j, 4, st] := r;
      end;
    end;
    close(fin);
  end;
  //generate average curve
  for y := 1 to 4 do
    for i := 0 to 100 do
    begin
      for j := 1 to k do
        curve[k + 1, y, i] := curve[k + 1, y, i] + curve[j, y, i];
      curve[k + 1, y, i] := curve[k + 1, y, i] / k;
    end;
  //write L1 output file
  assign(fout, 'L1_curves.csv');
  rewrite(fout);
  for i := 1 to k do
    write(fout, 'wrm', i, ',');
  writeln(fout, 'avg');
  for j := 1 to 100 do
  begin
    for i := 1 to k do
      write(fout, curve[i, 1, j], ',');
    writeln(fout, curve[k + 1, 1, j]);
  end;
  close(fout);
  //write L2 output file
  assign(fout, 'L2_curves.csv');
  rewrite(fout);
  for i := 1 to k do
    write(fout, 'wrm', i, ',');
  writeln(fout, 'avg');
  for j := 1 to 100 do
  begin
    for i := 1 to k do
      write(fout, curve[i, 2, j], ',');
    writeln(fout, curve[k + 1, 2, j]);
  end;
  close(fout);
  //write L3 output file
  assign(fout, 'L3_curves.csv');
  rewrite(fout);
  for i := 1 to k do
    write(fout, 'wrm', i, ',');
  writeln(fout, 'avg');
  for j := 1 to 100 do
  begin
    for i := 1 to k do
      write(fout, curve[i, 3, j], ',');
    writeln(fout, curve[k + 1, 3, j]);
  end;
  close(fout);
  //write L4 output file
  assign(fout, 'L4_curves.csv');
  rewrite(fout);
  for i := 1 to k do
    write(fout, 'wrm', i, ',');
  writeln(fout, 'avg');
  for j := 1 to 100 do
  begin
    for i := 1 to k do
      write(fout, curve[i, 4, j], ',');
    writeln(fout, curve[k + 1, 4, j]);
  end;
  close(fout);
end.