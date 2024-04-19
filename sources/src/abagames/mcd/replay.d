/*
 * $Id: replay.d,v 1.2 2006/02/22 22:27:47 kenta Exp $
 *
 * Copyright 2006 Kenta Cho. Some rights reserved.
 */
module abagames.mcd.replay;

private import std.stdio;
private import abagames.util.sdl.recordableinput;
private import abagames.util.sdl.twinstickpad;
private import abagames.mcd.gamemanager;

/**
 * Save/Load a replay data.
 */
public class ReplayData {
 public:
  static string dir = "replay";
  static const int VERSION_NUM = 10;
  InputRecord!(TwinStickPadState) twinStickPadInputRecord;
  long seed;
  int score = 0;
  int time = 0;
 private:

  public void save(string fileName) {
    scope File fd;
    int[1] write_data_int;
    long[1] write_data_long;
    fd.open(dir ~ "/" ~ fileName, "wb");
    write_data_int[0] = VERSION_NUM;
    fd.rawWrite(write_data_int);
    write_data_long[0] = seed;
    fd.rawWrite(write_data_long);
    write_data_int[0] = score;
    fd.rawWrite(write_data_int);
    write_data_int[0] = time;
    fd.rawWrite(write_data_int);
    twinStickPadInputRecord.save(fd);
    fd.close();
  }

  public void load(string fileName) {
    scope File fd;
    int[1] read_data_int;
    long[1] read_data_long;
    fd.open(dir ~ "/" ~ fileName);
    fd.rawRead(read_data_int);
    if (read_data_int[0] != VERSION_NUM)
      throw new Exception("Wrong version num");
    fd.rawRead(read_data_long);
    seed = read_data_long[0];
    fd.rawRead(read_data_int);
    score = read_data_int[0];
    fd.rawRead(read_data_int);
    time = read_data_int[0];
    twinStickPadInputRecord = new InputRecord!(TwinStickPadState);
    twinStickPadInputRecord.load(fd);
    fd.close();
  }
}
