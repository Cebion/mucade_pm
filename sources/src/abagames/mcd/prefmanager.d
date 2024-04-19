/*
 * $Id: prefmanager.d,v 1.1.1.1 2006/02/19 04:57:26 kenta Exp $
 *
 * Copyright 2006 Kenta Cho. Some rights reserved.
 */
module abagames.mcd.prefmanager;

private import std.stdio;
private import abagames.util.prefmanager;

/**
 * Handle a high score table.
 */
public class PrefManager: abagames.util.prefmanager.PrefManager {
 private:
  static const int VERSION_NUM = 10;
  static string PREF_FILE_NAME = "mcd.prf";
  PrefData _prefData;

  public this() {
    _prefData = new PrefData;
  }

  public void load() {
    scope File fd;
    try {
      int[1] read_data;
      fd.open(PREF_FILE_NAME);
      fd.rawRead(read_data);
      if (read_data[0] != VERSION_NUM)
        throw new Exception("Wrong version num");
      else
        _prefData.load(fd);
    } catch (Exception e) {
      _prefData.init();
    } finally {
      if (fd.isOpen())
        fd.close();
    }
  }

  public void save() {
    scope File fd;
    try {
      fd.open(PREF_FILE_NAME, "wb");
      int[1] write_data = [VERSION_NUM];
      fd.rawWrite(write_data);
      _prefData.save(fd);
    } finally {
      fd.close();
    }
  }

  public PrefData prefData() {
    return _prefData;
  }
}

public class PrefData {
 public:
  static const int RANKING_NUM = 10;
 private:
  int[RANKING_NUM] _highScore;
  int[RANKING_NUM] _time;

  public void init() {
    for(int i = 0; i < RANKING_NUM; i++) {
      _highScore[i] = (10 - i) * 10000;
      _time[i] = (10 - i) * 10000;
    }
  }

  public void load(File fd) {
    for(int i = 0; i < RANKING_NUM; i++) {
      int[2] read_data;
      fd.rawRead(read_data);
      _highScore[i] = read_data[0];
      _time[i] = read_data[1];
    }
  }

  public void save(File fd) {
    for(int i = 0; i < RANKING_NUM; i++) {
      int[2] write_data = [_highScore[i], _time[i]];
      fd.rawWrite(write_data);
    }
  }

  public void recordResult(int score, int t) {
    for(int i = 0; i < RANKING_NUM; i++) {
      if (score > _highScore[i]) {
        for (int j = RANKING_NUM - 1; j >= i + 1; j--) {
          _highScore[j] = _highScore[j - 1];
          _time[j] = _time[j - 1];
        }
        _highScore[i] = score;
        _time[i] = t;
        return;
      }
    }
  }

  public int[] highScore() {
    return _highScore;
  }

  public int[] time() {
    return _time;
  }
}
