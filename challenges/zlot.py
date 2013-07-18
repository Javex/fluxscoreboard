def loadState(self, statestr):
    try:
   dec = decrypt(statestr.decode("base64"))
   if '\x00' in dec:
       self.sendLine('Error loading game: invalid characters')
       return
   try:
       state = json.loads(dec)
   except Exception, e:
       self.sendLine('Error loading game: ' + str(e))
       return
   self.credits = state['credits']
   self.bonus = state['bonus']
   if self.bonus > 8:
       #XXX A few lines got lost in here during our recovery         
   self.sendLine('Restored state.')
   self.sendLine(self.msgs['BALANCE'] % (self.credits, self.bonus))
    except Exception, e:
   self.sendLine('Error loading game: ' + str(e))

# crypto stuff

def addPadding(data, block_size):
    data_len = len(data)+1 # required for the last byte
    pad_len = (block_size - data_len ) %  block_size
    pad_string = '\xff' * (pad_len) # arbitrary bytes to fill up block, -1 for last byte. generated below
    last_byte = struct.pack('<B', pad_len+1) # little-endian unsigned char, tells how many arbitrary bytes we have to remove
    return ''.join([data, pad_string, last_byte])
   
def delPadding(data, block_size):
    pad_len = struct.unpack('<B', data[-1])[0]
    if pad_len > block_size or pad_len < 1:
        raise ValueError("Encryption Error, Invalid Padding :/")
    else:
        return data[:(len(data)-pad_len)]


def encrypt(data, key=SECRET_KEY:
    iv = urandom(16)
    cipher_obj = AES.new(key, AES.MODE_CBC, iv)
    data = addPadding(data, 16)
    return iv+cipher_obj.encrypt(data)

def decrypt(data, key=SECRET_KEY):
    iv, data = data[:16], data[16:] # d'uh
    cipher_obj = AES.new(key, AES.MODE_CBC, iv)
    padded = cipher_obj.decrypt(data)
    return delPadding(padded, 16) 