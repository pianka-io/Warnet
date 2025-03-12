import logging
import discord
import asyncio
from discord.ext import commands

TOKEN = ""
GUILD_ID = 1332524138681598104
CHANNEL_ID = 1347641506143666176

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    force=True
)

intents = discord.Intents.default()
intents.messages = True
intents.guilds = True

bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    logging.info(f"Bot connected as {bot.user}")

async def send_message(message_content):
    await bot.wait_until_ready()
    guild = discord.utils.get(bot.guilds, id=GUILD_ID)
    if not guild:
        logging.error(f"Guild {GUILD_ID} not found")
        return

    channel = discord.utils.get(guild.channels, id=CHANNEL_ID)
    if not channel:
        logging.error(f"Channel {CHANNEL_ID} not found")
        return

    embed = discord.Embed(description=message_content)
    await channel.send(embed=embed)

async def run_discord_bot():
    await bot.start(TOKEN)
