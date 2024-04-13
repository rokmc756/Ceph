import asyncio

def hello():
    print('hello')

async def bye():
    print('bye')

async def main():
    await hello
    bye()

if __name__ == '__main__':
    asyncio.run(main())

