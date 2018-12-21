#include "qcustomplot/CustomPlotItem.h"

#include "qcustomplot.h"
#include <QDebug>
#include <algorithm>

CustomPlotItem::CustomPlotItem( QQuickItem* parent ) : QQuickPaintedItem( parent )
    , m_CustomPlot( new QCustomPlot() )
{
    connect( this, &QQuickPaintedItem::widthChanged, this, &CustomPlotItem::updateCustomPlotSize );
    connect( this, &QQuickPaintedItem::heightChanged, this, &CustomPlotItem::updateCustomPlotSize );
    connect( m_CustomPlot, &QCustomPlot::afterReplot, this, &CustomPlotItem::onCustomReplot );
    //binding "colorBackground" property
    connect(this, &CustomPlotItem::colorBackgroundChanged, this, &CustomPlotItem::setBackground);
}

CustomPlotItem::~CustomPlotItem()
{
    delete m_CustomPlot;
    m_CustomPlot = nullptr;
}

void CustomPlotItem::initCustomPlot()
{
    QString color = "#aaffffff";
    m_CustomPlot->xAxis->setTickLabelRotation(60);
    m_CustomPlot->xAxis->setTickLength(0, 4);
    m_CustomPlot->xAxis->setRange(0, 6);

    m_CustomPlot->yAxis->setTickLength(0, 4);

    m_CustomPlot->xAxis->setTickLabelColor(QColor(color));
    m_CustomPlot->xAxis->setLabelColor(QColor(color));
    m_CustomPlot->xAxis->setSubTickPen(QPen(color));
    m_CustomPlot->xAxis->setTickPen(QPen(color));
    m_CustomPlot->xAxis->setSubTicks(false);
    m_CustomPlot->xAxis->setLabel("Time");

    m_CustomPlot->yAxis->setTickLabelColor(QColor(color));
    m_CustomPlot->yAxis->setLabelColor(QColor(color));
    m_CustomPlot->yAxis->setSubTickPen(QPen(color));
    m_CustomPlot->yAxis->setTickPen(QPen(color));
    m_CustomPlot->yAxis->setSubTicks(false);
    m_CustomPlot->yAxis->setLabel("°C");

    resetPlot();

    QSharedPointer<QCPAxisTickerTime> timeTicker(new QCPAxisTickerTime);
    timeTicker->setTimeFormat("%h:%m");

    m_CustomPlot->xAxis->setTicker(timeTicker);

    m_CustomPlot->replot();
}

void CustomPlotItem::setPlotData(QString time, QVector<double> minTemp, QVector<double> maxTemp)
{
    resetPlot();// making plot work properly, we have to reset plot. TODO: there should be another way that no need to reset plot every time.
    QVector<double> ticks;
    QVector<QString> labels;
    QStringList xValue = time.split(",");
    for (int idx = 0; idx < xValue.size(); ++idx) {
        labels.append(xValue.at(idx));
    }
    ticks << 1 << 2 << 3 << 4 << 5 << 6;

    QSharedPointer<QCPAxisTickerText> textTicker(new QCPAxisTickerText);
    textTicker->addTicks(ticks, labels);
    m_CustomPlot->xAxis->setTicker(textTicker);

    //find the best fit for range
    auto minMinTemp = *std::min_element(minTemp.constBegin(), minTemp.constEnd());
    auto maxMinTemp = *std::max_element(minTemp.constBegin(), minTemp.constEnd());
    auto minMaxTemp = *std::min_element(maxTemp.constBegin(), maxTemp.constEnd());
    auto maxMaxTemp = *std::max_element(maxTemp.constBegin(), maxTemp.constEnd());
    auto minRange = (minMinTemp < minMaxTemp) ? minMinTemp : minMaxTemp;
    auto maxRange = (maxMinTemp > maxMaxTemp) ? maxMinTemp : maxMaxTemp;

    m_CustomPlot->yAxis->setRange(minRange, maxRange);

    m_CustomPlot->graph(m_minGraphIndex)->addData(ticks, minTemp);
    m_CustomPlot->graph(m_maxGraphIndex)->addData(ticks, maxTemp);
    m_CustomPlot->replot();
    setVisiblity(true);
}

void CustomPlotItem::setVisiblity(bool value)
{
    setVisible(value);
}

void CustomPlotItem::setBackground(QColor color)
{
    m_CustomPlot->setBackground(QBrush(color));
    m_CustomPlot->axisRect()->setBackground(QBrush(color));
    m_CustomPlot->xAxis->setBasePen(QPen(color));
    m_CustomPlot->yAxis->setBasePen(QPen(color));
}

void CustomPlotItem::paint( QPainter* painter )
{
    if (m_CustomPlot)
    {
        QPixmap    picture( boundingRect().size().toSize() );
        QCPPainter qcpPainter( &picture );

        //m_CustomPlot->replot();
        m_CustomPlot->toPainter( &qcpPainter );

        painter->drawPixmap( QPoint(), picture );
    }
}

QColor CustomPlotItem::getColorBackground()
{
    return _colorBackground;
}

void CustomPlotItem::setColorBackground(QColor color)
{
    if (color != _colorBackground)
    {
        _colorBackground = color;
        m_CustomPlot->replot();// replot in order to affect plot
        emit colorBackgroundChanged(color);
    }
}

void CustomPlotItem::resetPlot()
{
    m_CustomPlot->clearGraphs();
    m_CustomPlot->addGraph(); // blue line
    m_CustomPlot->graph(m_minGraphIndex)->setPen(QPen(QColor(0, 0, 255)));
    m_CustomPlot->addGraph(); // red line
    m_CustomPlot->graph(m_maxGraphIndex)->setPen(QPen(QColor(255, 0, 0)));
}

void CustomPlotItem::updateCustomPlotSize()
{
    if (m_CustomPlot)
    {
        m_CustomPlot->setGeometry( 0, 0, width(), height() );
    }
}

void CustomPlotItem::onCustomReplot()
{
    qDebug() << Q_FUNC_INFO;
    update();
}
