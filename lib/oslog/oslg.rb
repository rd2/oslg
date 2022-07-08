# BSD 3-Clause License
#
# Copyright (c) 2022, Denis Bourgeois
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This module is a rehash of TBD's log solution (MIT-licensed):
#
#   https://github.com/rd2/tbd/blob/master/lib/log.rb

module CNST
  DEBUG = 1
  INFO  = 2
  WARN  = 3
  ERROR = 4
  FATAL = 5
end

module OSLog
  @@logs             = []
  @@level            = CNST::INFO

  @@tag              = []
  @@tag[0          ] = ""
  @@tag[CNST::DEBUG] = "DEBUG"
  @@tag[CNST::INFO ] = "INFO"
  @@tag[CNST::WARN ] = "WARNING"
  @@tag[CNST::ERROR] = "ERROR"
  @@tag[CNST::FATAL] = "FATAL"

  @@msg              = []
  @@msg[0          ] = ""
  @@msg[CNST::DEBUG] = "Debugging ..."
  @@msg[CNST::INFO ] = "Success! No errors, no warnings"
  @@msg[CNST::WARN ] = "Partial success, raised non-fatal warnings"
  @@msg[CNST::ERROR] = "Partial success, encountered non-fatal errors"
  @@msg[CNST::FATAL] = "Failure, triggered fatal errors"

  # Highest log level reached so far in process sequence.
  @@status = 0

  def logs
    @@logs
  end

  def level
    @@level
  end

  def status
    @@status
  end

  def debug?
    return @@status == CNST::DEBUG
  end

  def info?
    return @@status == CNST::INFO
  end

  def warn?
    return @@status == CNST::WARN
  end

  def error?
    return @@status == CNST::ERROR
  end

  def fatal?
    return @@status == CNST::FATAL
  end

  def tag(level)
    return @@tag[level] if level >= CNST::DEBUG && level <= CNST::FATAL
    return ""
  end

  def msg(status)
    if level >= CNST::DEBUG && level <= CNST::FATAL return @@msg[status]
    return ""
  end

  def set_level(level)
    @@level = level
  end

  def log(level, message)
    if level >= @@level
      @@logs << { level: level, message: message }

      @@status = level if level > @@status
    end
  end

  def clean!
    @@level = CNST::INFO
    @@status = 0
    @@logs = []
  end

  def self.extended(base)
    base.send(:include, self)
  end
end
