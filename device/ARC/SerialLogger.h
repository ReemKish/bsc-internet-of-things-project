// Copyright (c) Microsoft Corporation. All rights reserved.
// SPDX-License-Identifier: MIT
#include <Arduino.h>

#ifndef SERIALLOGGER_H
#define SERIALLOGGER_H


#ifndef SERIAL_LOGGER_BAUD_RATE
#define SERIAL_LOGGER_BAUD_RATE 115200
#endif

class SerialLogger
{
public:
  SerialLogger();
  void Info(String message);
  void Error(String message);
};

extern SerialLogger Logger;

#endif // SERIALLOGGER_H
