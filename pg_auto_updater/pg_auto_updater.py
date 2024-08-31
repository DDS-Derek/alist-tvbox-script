import cryptg
from telethon.sync import TelegramClient
from telethon.tl.types import InputMessagesFilterDocument
import time
import zipfile
import os
import shutil
import logging
import json
import os
import sys
import docker
import signal


progress_tracker = {'last_downloaded_bytes': 0, 'start_time': time.time()}
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def signal_handler(sig, frame):
    logging.info('PG 更新助手关闭中...')
    sys.exit(0)


def load_config(config_dir):
    if not os.path.exists(f"{config_dir}/config.json"):
        default_config = {
            "api_id": "api_id",
            "api_hash": "api_hash",
            "tvbox_container_name": "tvbox_container_name"
        }
        with open(f"{config_dir}/config.json", "w") as json_file:
            json.dump(default_config, json_file, indent=4)
            logging.info("config.json 已生成，请在该文件中填写 api_id 和 api_hash 然后重新运行程序。")
            sys.exit()
    else:
        with open(f"{config_dir}/config.json") as json_data_file:
            data = json.load(json_data_file)
        return data


def restart_container(container_name):
    client = docker.from_env()
    containers = client.containers.list(all=True)
    for container in containers:
        if container.name == container_name:
            try:
                container.restart()
                logging.info(f'容器 {container_name} 已成功重启.')
            except Exception as e:
                logging.error(f'容器 {container_name} 重启失败. Reason: {str(e)}')
            finally:
                client.close()
                break


def unzip(zip_filepath, dest_dir):
    with zipfile.ZipFile(zip_filepath, 'r') as zip_ref:
        zip_ref.extractall(dest_dir)
    logging.info(f'已解压 {zip_filepath} 到 {dest_dir}')


def display_progress(downloaded_bytes, total_bytes):
    current_speed = (downloaded_bytes - progress_tracker['last_downloaded_bytes'])/(time.time() - progress_tracker['start_time'])
    progress_tracker['last_downloaded_bytes'] = downloaded_bytes
    progress_tracker['start_time'] = time.time()
    logging.info("已下载：{:.2f}MB，总计：{:.2f}MB，下载速度: {:.2f}KB/s".format(downloaded_bytes / 1024 / 1024,
                                                          total_bytes / 1024 / 1024,
                                                          current_speed / 1024))


def download(config_dir, api_id, api_hash):
    channel_username = 'PandaGroovePG'
    with TelegramClient(f"{config_dir}/updater", api_id, api_hash) as client:
        messages = client.get_messages(channel_username, None, filter=InputMessagesFilterDocument)
        for message in messages:
            if message.media.document.attributes[-1].file_name.startswith('pg') and message.media.document.attributes[-1].file_name.endswith('.zip'):
                client.download_media(message=message, file='./downloads/pg.zip', progress_callback=display_progress)
                logging.info('文件已下载')
                break


def move_files(pg_data_dir):
    for filename in os.listdir(pg_data_dir):
        file_path = os.path.join(pg_data_dir, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            logging.error(f'删除 {file_path} 时出错。原因: {e}')
    for filename in os.listdir('./temp'):
        shutil.move(os.path.join('./temp', filename), pg_data_dir)


def main():
    signal.signal(signal.SIGTERM, signal_handler)
    try:
        while True:
            if sys.platform.startswith('win'):
                pg_data_dir = './pg'
            else:
                pg_data_dir = '/data'
            if sys.platform.startswith('win'):
                config_dir = './config'
            else:
                config_dir = '/config'
            if not os.path.isdir(config_dir):
                os.mkdir(config_dir)
            config = load_config(config_dir)
            if not os.path.isdir('./downloads'):
                os.mkdir('./downloads')
            if not os.path.isdir(pg_data_dir):
                os.mkdir(pg_data_dir)
            if os.path.isdir('./temp'):
                shutil.rmtree('./temp')
            os.mkdir('./temp')
            if os.path.isfile('./downloads/pg.zip'):
                os.remove('./downloads/pg.zip')
            download(config_dir, config["api_id"], config["api_hash"])
            unzip('./downloads/pg.zip', './temp')
            move_files(pg_data_dir)
            time.sleep(2)
            restart_container(config["tvbox_container_name"])
            logging.info(f"本次运行完成，等待 24H 后下一次运行")
            time.sleep(24*60*60)
    except KeyboardInterrupt:
        logging.info('PG 更新助手关闭中...')
    finally:
        logging.info('PG 更新助手已关闭')


if __name__ == '__main__':
    main()
