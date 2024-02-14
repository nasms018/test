class FourCal:
    def __init__(self, first, second):
        self.first = first
        self.second = second
    def setdata(self, first, second):
        self.first = first
        self.second = second
    def add(self):
        return self.first + self.second

a= FourCal(1,3)
print(a.first)
print(a.second)
print(a.add())


