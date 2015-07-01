package com.example.taiho.myapplication;

import android.content.Context;
import android.util.Base64;
import android.util.Log;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.RSAPublicKeySpec;

import javax.crypto.Cipher;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

/**
 * Created by taiho on 6/23/15.
 */
public class RSA {

    private final String CIPHER_ALGORITHM = "RSA";
    private final String RSA_CIPHER_MODE = "RSA/ECB/PKCS1Padding";

    private PublicKey publicKey = null;


    private Context context;
    public RSA(){

    }

    public RSA(Context context, String publicKeyFile) throws NoSuchAlgorithmException, InvalidKeySpecException, UnsupportedEncodingException, SAXException, IOException, ParserConfigurationException {
        try {
            this.context = context;
            createPublicKey(publicKeyFile);
        }catch (Exception ex){
            throw ex;
        }
    }

    private void createPublicKey(String publicKeyFile)throws NoSuchAlgorithmException, InvalidKeySpecException, UnsupportedEncodingException, SAXException, IOException, ParserConfigurationException{
        try {

            /*
            * XML Public Key: <BitStrength>1024</BitStrength>
            *                 <RSAKeyValue>
            *                     <Modulus>
            *                         p42xDYUk1/kz1EeIlGtxUEZEv3rFRlxOOp0JKx3470DNcTgJ0pizMeBm3lZbl5wYD1Tk/CMH2jKf7tLfvHhL0skgbm0PQqIDLKgH7GgzMHsLLZa+Fz1udoK6UlZD50X0gHZ6UKIiR0APQgjZNCDqEMS4jaKHjp06duQOQm/s5mk=
            *                     </Modulus>
            *                     <Exponent>
            *                         AQAB
            *                     </Exponent>
            *                 </RSAKeyValue>
            * */
            InputStream publicKeyInputStream = context.getAssets().open(publicKeyFile);
            Document document = null;
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

            BufferedReader r = new BufferedReader(new InputStreamReader(publicKeyInputStream));
            StringBuilder total = new StringBuilder();
            String line;
            while ((line = r.readLine()) != null) {
                total.append(line);
            }

            String rawValue = total.toString();
            String rsaKeyValue = rawValue.substring(rawValue.indexOf("</BitStrength>") + "</BitStrength>".length());

            DocumentBuilder db = factory.newDocumentBuilder();
            InputSource inputSource = new InputSource(new ByteArrayInputStream(rsaKeyValue.getBytes("UTF-8")));
            document = db.parse(inputSource);


            Element rsaKeyValueElement = (Element)document.getElementsByTagName("RSAKeyValue").item(0);
            Node modulusElement = rsaKeyValueElement.getElementsByTagName("Modulus").item(0);
            Node exponentElement = rsaKeyValueElement.getElementsByTagName("Exponent").item(0);


            byte[] expBytes = Base64.decode(exponentElement.getTextContent(), Base64.DEFAULT);
            byte[] modBytes = Base64.decode(modulusElement.getTextContent(), Base64.DEFAULT);

            BigInteger modules = new BigInteger(1, modBytes);
            BigInteger exponent = new BigInteger(1, expBytes);

            KeyFactory keyFactory = KeyFactory.getInstance(CIPHER_ALGORITHM);
            RSAPublicKeySpec pubSpec = new RSAPublicKeySpec(modules, exponent);
            publicKey = keyFactory.generatePublic(pubSpec);

        }catch (Exception ex){
            throw ex;
        }
    }
    public String encrypt(String plainText) throws RuntimeException {
        if (publicKey != null) {

            try {
                Cipher rsaCipher = Cipher.getInstance(RSA_CIPHER_MODE);
                rsaCipher.init(Cipher.ENCRYPT_MODE, publicKey);

                byte[] bytes = plainText.getBytes("UTF-8");
                return Base64.encodeToString(rsaCipher.doFinal(bytes), Base64.DEFAULT);

            } catch (Exception e) {
                Log.e(this.getClass().getName(), "Error while encrypting data: " + e.getMessage());
                throw new RuntimeException(e);
            }
        } else throw new RuntimeException("Invalid Public Key");
    }
}
