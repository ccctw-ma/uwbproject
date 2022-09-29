package com.funtl.hello.nousenow;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

import java.util.ResourceBundle;

/**
 * Jedis工具类
 * @author LingZhe
 */
public class JedisUtil {

    // 设置参数
    private static String host;
    private static int port;
    private static String password;
    private static int maxtotal;
    private static int maxwaitmillis;
    private static int timeout;

    private static JedisPool jedisPool;

    // 加载配置文件并给参数赋值
    static {
        ResourceBundle rb = ResourceBundle.getBundle("jedis");
        maxtotal = Integer.parseInt(rb.getString("maxtotal"));
        maxwaitmillis = Integer.parseInt(rb.getString("maxwaitmillis"));
        port = Integer.parseInt(rb.getString("port"));
        host = rb.getString("host");
        password = rb.getString("password");
        timeout = Integer.parseInt(rb.getString("timeout"));
    }

    //初始化连接池
    static {
        JedisPoolConfig config = new JedisPoolConfig();
        config.setMaxTotal(maxtotal);
        config.setMaxWaitMillis(maxwaitmillis);
        jedisPool = new JedisPool(config, host, port, timeout, password);
    }

    /**
     * 获取连接方法
     * @return
     */
    public static Jedis getJedis() {
        Jedis jedis = jedisPool.getResource();
        return jedis;
    }

    /**
     *
     * @param jedis
     */
    public static void closeJedis(Jedis jedis) {
        if (null != jedis) {
            jedis.close();
        }
    }

    /**
     * 存值
     * @param key
     * @param value
     */
    public static void set(String key, String value) {
        Jedis jedis = getJedis();
        if (jedis != null) {
            String result = jedis.set(key, value);
//            System.out.println(result);
            closeJedis(jedis);
        }
    }

    /**
     * 取值
     * @param key
     * @return
     */
    public static String get(String key) {
        Jedis jedis = getJedis();
        String value = "";
        if (jedis != null) {
            value = jedis.get(key);
            closeJedis(jedis);
        }
        return value;
    }

}
