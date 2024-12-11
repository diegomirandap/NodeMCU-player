wificonf = {
  ssid = "nodemcu12",
  pwd = "reativos",
  save = false,
  got_ip_cb = function (con)
                print (con.IP)
                envia()
              end
}

wifi.sta.config(wificonf)
print("modo: ".. wifi.setmode(wifi.STATION))

local tempos = {}
local num_repeticoes = 3
local contagem = 1

local function calcular_media_tempos(valores)
  local soma = 0
  for _, v in ipairs(valores) do
      soma = soma + v
  end
  return soma / #valores
end

function envia()
  local udp_server = net.createUDPSocket()
  udp_server:listen(1234) -- Porta para receber mensagens
  
  local tempo_atual = tmr.now()
  udp_server:send(1234,"192.168.0.20",tempo_atual)
  print("enviou",contagem)

  udp_server:on('sent', function()
    print('enviou')
  end)
  udp_server:on("receive",function(socket, message, port, ip)
      local tempo_recebido = tonumber(message)
      if tempo_recebido then
        local tempo_retorno = tmr.now()
        local diff = tempo_recebido - tempo_atual
        tempos[#tempos + 1] = diff/2
        print(message,tempo_retorno-tempo_atual)
        contagem = contagem + 1 
        
        if contagem <= num_repeticoes then
          --Repete o envio um total de 3 vezes para obter uma media do tempo de envio
          tempo_atual = tmr.now()
          --udp_server:send(1234,"192.168.0.20",tempo_atual)
          udp_server:send(port,ip,tempo_atual) --n tem pq n reconhecer desta maneira, mas por precaucao deixei o hardcoded acima
          print("enviou",contagem)
        else
          local media = calcular_media_tempos(tempos)
          print("Tempo medio de latencia",media)

          -- Aguarda 10 segundos e envia a mensagem de execução
          local timer = tmr.create()
          local mensagem = "INICIO"
          udp_server:send(port, ip, mensagem)

          tocar_musica()

          -- timer:alarm(5000, tmr.ALARM_SINGLE, function()
          --     local mensagem = "INICIO"
          --     udp_server:send(port, ip, mensagem)
          --     print("enviou", mensagem)
          -- end)
          -- timer:alarm(media,tmr.ALARM_SINGLE, tocar_musica())
        end
      end
  end)
end

local notes = {
  C0  = 16.35,   Cs0 = 17.32,   D0  = 18.35,   Ds0 = 19.45,   E0  = 20.60,
  F0  = 21.83,   Fs0 = 23.12,   G0  = 24.50,   Gs0 = 25.96,   A0  = 27.50,
  As0 = 29.14,   B0  = 30.87,

  C1  = 32.70,   Cs1 = 34.65,   D1  = 36.71,   Ds1 = 38.89,   E1  = 41.20,
  F1  = 43.65,   Fs1 = 46.25,   G1  = 49.00,   Gs1 = 51.91,   A1  = 55.00,
  As1 = 58.27,   B1  = 61.74,

  C2  = 65.41,   Cs2 = 69.30,   D2  = 73.42,   Ds2 = 77.78,   E2  = 82.41,
  F2  = 87.31,   Fs2 = 92.50,   G2  = 98.00,   Gs2 = 103.83,  A2  = 110.00,
  As2 = 116.54,  B2  = 123.47,

  C3  = 130.81,  Cs3 = 138.59,  D3  = 146.83,  Ds3 = 155.56,  E3  = 164.81,
  F3  = 174.61,  Fs3 = 185.00,  G3  = 196.00,  Gs3 = 207.65,  A3  = 220.00,
  As3 = 233.08,  B3  = 246.94,

  C4  = 261.63,  Cs4 = 277.18,  D4  = 293.66,  Ds4 = 311.13,  E4  = 329.63,
  F4  = 349.23,  Fs4 = 369.99,  G4  = 392.00,  Gs4 = 415.30,  A4  = 440.00,
  As4 = 466.16,  B4  = 493.88,

  C5  = 523.25,  Cs5 = 554.37,  D5  = 587.33,  Ds5 = 622.25,  E5  = 659.25,
  F5  = 698.46,  Fs5 = 739.99,  G5  = 783.99,  Gs5 = 830.61,  A5  = 880.00,
  As5 = 932.33,  B5  = 987.77,

  C6  = 1046.50, Cs6 = 1108.73, D6  = 1174.66, Ds6 = 1244.51, E6  = 1318.51,
  F6  = 1396.91, Fs6 = 1479.98, G6  = 1567.98, Gs6 = 1661.22, A6  = 1760.00,
  As6 = 1864.66, B6  = 1975.53,

  C7  = 2093.00, Cs7 = 2217.46, D7  = 2349.32, Ds7 = 2489.02, E7  = 2637.02,
  F7  = 2793.83, Fs7 = 2959.96, G7  = 3135.96, Gs7 = 3322.44, A7  = 3520.00,
  As7 = 3729.31, B7  = 3951.07,

  C8  = 4186.01, Cs8 = 4434.92, D8  = 4698.64, Ds8 = 4978.03, REST = 0
}


function tocar_musica()
  
  local buzzerPin = 7 -- D7 (GPIO13)

  -- Configura o PWM no pino do buzzer
  pwm.setup(buzzerPin, 500, 512) -- Frequência inicial de 500 Hz, ciclo de trabalho 50%

  -- Função para tocar uma nota
  function playNote(freq, duration)
      if freq > 0 then
          pwm.setclock(buzzerPin, freq) -- Define a frequência
          pwm.start(buzzerPin)          -- Inicia o som
      else
          pwm.stop(buzzerPin)           -- Silêncio para pausas
      end
      tmr.create():alarm(duration, tmr.ALARM_SINGLE, function()
          pwm.stop(buzzerPin)           -- Para o som após a duração
      end)
  end

  local melody = {
    {freq = notes["REST"], duration = 150},
    {freq = notes["Fs5"], duration = 100},
    {freq = notes["REST"], duration = 100},
    {freq = notes["B4"], duration = 300},
    {freq = notes["REST"], duration = 300},
    {freq = notes["E5"], duration = 300},
    {freq = notes["REST"], duration = 300},
    {freq = notes["E5"], duration = 100},
    {freq = notes["REST"], duration = 100},
    {freq = notes["Gs5"], duration = 100},
    {freq = notes["REST"], duration = 100},
    {freq = notes["B5"], duration = 100},

    {freq = notes["REST"], duration = 100},
    {freq = notes["A5"], duration = 100},
    {freq = notes["REST"], duration = 100},
    {freq = notes["E5"], duration = 300},
    {freq = notes["REST"], duration = 300},
    {freq = notes["Fs5"], duration = 300},
    {freq = notes["REST"], duration = 300},
    {freq = notes["Fs5"], duration = 100},
    {freq = notes["REST"], duration = 100},
    {freq = notes["E5"], duration = 100},
    {freq = notes["REST"], duration = 100},
    {freq = notes["E5"], duration = 100},
  }

  -- Função para tocar a melodia
  function playMelody(melody, index)
      if index > #melody then return end
      local note = melody[index]
      playNote(note.freq, note.duration)
      tmr.create():alarm(note.duration + 50, tmr.ALARM_SINGLE, function()
          playMelody(melody, index + 1)
      end)
  end

  -- Tocar a melodia
  playMelody(melody, 1)


end
