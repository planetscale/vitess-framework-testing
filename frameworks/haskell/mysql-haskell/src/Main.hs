{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import qualified BinaryRow
import qualified BinaryRowNew
import qualified BinLog
import qualified BinLogNew
import           Control.Concurrent    (forkIO, threadDelay)
import           Control.Exception     (bracket, catch)
import           Control.Monad
import qualified Data.ByteString       as B
import           Data.ByteString.Char8
import           Database.MySQL.Base
import           Database.MySQL.BinLog
import           Network.Socket
import           System.Environment
import qualified System.IO.Streams as Stream
import           Test.Tasty
import           Test.Tasty.HUnit
import qualified TextRow
import qualified ExecuteMany
import qualified TextRowNew

main :: IO ()
main = defaultMain $ testCaseSteps "mysql-haskell test suite" $ \step -> do
    step "reading env..."
    host <- getEnv "VT_HOST"
    port <- getEnv "VT_PORT"
    user <- getEnv "VT_USERNAME"
    password <- getEnv "VT_PASSWORD"
    database <- getEnv "VT_DATABASE"

    step "connecting..."
    (greet, c) <- connectDetail defaultConnectInfo{
        ciHost = host,
        ciPort = read port :: PortNumber,
        ciUser = pack user,
        ciPassword = pack password,
        ciDatabase = pack database
    }

    step "preparing table..."
    let ver = greetingVersion greet
        isNew = "5.6" `B.isPrefixOf` ver
                || "5.7" `B.isPrefixOf` ver  -- from MySQL 5.6.4 and up
                                             -- TIME, DATETIME, and TIMESTAMP support fractional seconds

    step "setting max_allowed_packet..."
    execute_ c "SET GLOBAL max_allowed_packet=32 * 1024 * 1024"

    execute_ c "DROP TABLE IF EXISTS test"
    execute_ c "DROP TABLE IF EXISTS test_new"

    execute_ c  "CREATE TABLE test(\
                \__id           INT,\
                \__bit          BIT(16),\
                \__tinyInt      TINYINT,\
                \__tinyIntU     TINYINT UNSIGNED,\
                \__smallInt     SMALLINT,\
                \__smallIntU    SMALLINT UNSIGNED,\
                \__mediumInt    MEDIUMINT,\
                \__mediumIntU   MEDIUMINT UNSIGNED,\
                \__int          INT,\
                \__intU         INT UNSIGNED,\
                \__bigInt       BIGINT,\
                \__bigIntU      BIGINT UNSIGNED,\
                \__decimal      DECIMAL(20,10),\
                \__float        FLOAT,\
                \__double       DOUBLE,\
                \__date         DATE,\
                \__datetime     DATETIME,\
                \__timestamp    TIMESTAMP NULL,\
                \__time         TIME,\
                \__year         YEAR(4),\
                \__char         CHAR(8),\
                \__varchar      VARCHAR(1024),\
                \__binary       BINARY(8),\
                \__varbinary    VARBINARY(1024),\
                \__tinyblob     TINYBLOB,\
                \__tinytext     TINYTEXT,\
                \__blob         BLOB(1000000),\
                \__text         TEXT(1000000),\
                \__enum         ENUM('foo', 'bar', 'qux'),\
                \__set          SET('foo', 'bar', 'qux')\
                \) CHARACTER SET utf8"

    resetTestTable c

    step "testing executeMany"
    ExecuteMany.tests c

    resetTestTable c

    step "testing text protocol"
    TextRow.tests c

    resetTestTable c

    step "testing binary protocol"
    BinaryRow.tests c

    resetTestTable c


    when isNew $ do
        execute_ c "CREATE TABLE test_new(\
                   \__id           INT,\
                   \__datetime     DATETIME(2),\
                   \__timestamp    TIMESTAMP(4) NULL,\
                   \__time         TIME(6)\
                   \) CHARACTER SET utf8"

        resetTest57Table c

        step "testing MySQL5.7 extra text protocol"
        TextRowNew.tests c

        resetTest57Table c

        step "testing MySQL5.7 extra binary protocol"
        BinaryRowNew.tests c

        void $ resetTest57Table c

    step "testing binlog protocol"

-- TODO:  https://github.com/vitessio/vitess/issues/6973
--    if isNew
--    then do
--        forkIO BinLogNew.eventProducer
--        BinLogNew.tests c
--    else do
--        forkIO BinLog.eventProducer
--        BinLog.tests c

    Database.MySQL.Base.close c

-- TODO:  Do we care about precise authentication error text?
--    let loginFailMsg = "ERRException (ERR {errCode = 1045, errState = \"28000\", \
--            \errMsg = \"Access denied for user 'testMySQLHaskell'@'localhost' (using password: YES)\"})"
--
--    catch
--        (void $ connectDetail defaultConnectInfo{
--            ciHost = host,
--            ciPort = read port :: PortNumber,
--            ciUser = pack user,
--            ciPassword = "wrongpassword",
--            ciDatabase = pack database
--        })
--        (\ (e :: ERRException) -> assertEqual "wrong password should fail to login" (show e) loginFailMsg)

  where
    resetTestTable c = do
            execute_ c  "DELETE FROM test WHERE __id=0"
            execute_ c  "INSERT INTO test VALUES(\
                    \0,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL,\
                    \NULL\
                    \)"

    resetTest57Table c = do
            execute_ c  "DELETE FROM test_new WHERE __id=0"
            execute_ c  "INSERT INTO test_new VALUES(\
                        \0,\
                        \NULL,\
                        \NULL,\
                        \NULL\
                        \)"


