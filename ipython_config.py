c = get_config()

c.InteractiveShellApp.exec_lines = [
    "mpl.rc('font', family='NanumGothic')",  # 나눔고딕 폰트 사용
    "mpl.rc('axes', unicode_minus=False)",  # 유니코드 음수 기호 사용
    "mpl.rc('figure', figsize=(8, 5))",  # 그림 크기 (단위: 인치)
    "mpl.rc('figure', dpi=300)",  # 그림 해상도
]
